require("dotenv").config();

const express = require("express");
const cors = require("cors");
const axios = require("axios");
const admin = require("firebase-admin");

const app = express();

app.use(cors());
app.use(express.json());

const requiredEnv = [
  "BREVO_API_KEY",
  "BREVO_SENDER_EMAIL",
  "FIREBASE_PROJECT_ID",
  "FIREBASE_CLIENT_EMAIL",
  "FIREBASE_PRIVATE_KEY",
];

for (const key of requiredEnv) {
  if (!process.env[key]) {
    console.error(`Missing environment variable: ${key}`);
  }
}

admin.initializeApp({
  credential: admin.credential.cert({
    projectId: process.env.FIREBASE_PROJECT_ID,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
  }),
});

const db = admin.firestore();

function generateOtp() {
  return Math.floor(1000 + Math.random() * 9000).toString();
}

function normalizeEmail(email) {
  return String(email || "").trim().toLowerCase();
}

app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "Moodly backend is running.",
  });
});

app.post("/send-register-otp", async (req, res) => {
  try {
    const fullName = String(req.body.fullName || "").trim();
    const email = normalizeEmail(req.body.email);

    if (!fullName || !email || !email.includes("@")) {
      return res.status(400).json({
        success: false,
        message: "Nama dan email wajib diisi dengan benar.",
      });
    }

    try {
      await admin.auth().getUserByEmail(email);

      return res.status(409).json({
        success: false,
        message: "Email sudah digunakan.",
      });
    } catch (error) {
      if (error.code !== "auth/user-not-found") {
        console.error("CHECK EMAIL ERROR:", error);

        return res.status(500).json({
          success: false,
          message: "Gagal mengecek email.",
        });
      }
    }

    const otp = generateOtp();
    const expiresAt = Date.now() + 5 * 60 * 1000;

    await db.collection("email_otps").doc(email).set({
      email,
      fullName,
      otp,
      expiresAt,
      used: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const htmlContent = `
      <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #222; max-width: 560px; margin: 0 auto;">
        <div style="background:#F3FADC; padding:24px; border-radius:18px;">
          <h2 style="color:#5FA84D; margin-top:0;">Halo ${fullName},</h2>

          <p>Terima kasih sudah bergabung dengan <strong>Moodly</strong>.</p>

          <p>
            Moodly adalah ruang kecil yang aman untuk menulis, bercerita,
            dan memahami perasaanmu pelan-pelan.
          </p>

          <p>Gunakan kode OTP berikut untuk memverifikasi akunmu:</p>

          <div style="font-size:32px; font-weight:bold; letter-spacing:8px; background:#ffffff; padding:16px 24px; border-radius:14px; display:inline-block; color:#222;">
            ${otp}
          </div>

          <p style="margin-top:20px;">Kode ini berlaku selama <strong>5 menit</strong>.</p>

          <p>
            Jika kamu tidak merasa membuat akun Moodly, kamu bisa mengabaikan email ini.
          </p>

          <p style="margin-bottom:0;">
            Salam hangat,<br/>
            <strong>Tim Moodly</strong>
          </p>
        </div>
      </div>
    `;

    await axios.post(
      "https://api.brevo.com/v3/smtp/email",
      {
        sender: {
          name: process.env.BREVO_SENDER_NAME || "Moodly",
          email: process.env.BREVO_SENDER_EMAIL,
        },
        to: [
          {
            email,
            name: fullName,
          },
        ],
        subject: "Kode verifikasi akun Moodly kamu",
        htmlContent,
      },
      {
        headers: {
          "api-key": process.env.BREVO_API_KEY,
          "Content-Type": "application/json",
        },
      }
    );

    return res.json({
      success: true,
      message: "Kode OTP berhasil dikirim.",
    });
  } catch (error) {
    console.error("SEND OTP ERROR:", error.response?.data || error.message);

    return res.status(500).json({
      success: false,
      message: "Gagal mengirim OTP. Silakan coba lagi.",
    });
  }
});

app.post("/verify-register-otp", async (req, res) => {
  try {
    const fullName = String(req.body.fullName || "").trim();
    const email = normalizeEmail(req.body.email);
    const phoneNumber = String(req.body.phoneNumber || "").trim();
    const password = String(req.body.password || "");
    const otp = String(req.body.otp || "").trim();

    if (!fullName || !email || !phoneNumber || !password || !otp) {
      return res.status(400).json({
        success: false,
        message: "Semua data wajib diisi.",
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: "Kata sandi minimal 6 karakter.",
      });
    }

    if (otp.length !== 4) {
      return res.status(400).json({
        success: false,
        message: "Kode OTP harus 4 digit.",
      });
    }

    const otpRef = db.collection("email_otps").doc(email);
    const otpSnap = await otpRef.get();

    if (!otpSnap.exists) {
      return res.status(404).json({
        success: false,
        message: "Kode OTP tidak ditemukan. Silakan kirim ulang kode.",
      });
    }

    const otpData = otpSnap.data();

    if (otpData.used === true) {
      return res.status(400).json({
        success: false,
        message: "Kode OTP sudah digunakan.",
      });
    }

    if (Date.now() > otpData.expiresAt) {
      return res.status(400).json({
        success: false,
        message: "Kode OTP sudah kedaluwarsa. Silakan kirim ulang kode.",
      });
    }

    if (otpData.otp !== otp) {
      return res.status(400).json({
        success: false,
        message: "Kode OTP salah.",
      });
    }

    const phoneQuery = await db
      .collection("users")
      .where("phoneNumber", "==", phoneNumber)
      .limit(1)
      .get();

    if (!phoneQuery.empty) {
      return res.status(409).json({
        success: false,
        message: "Nomor telepon sudah digunakan.",
      });
    }

    let userRecord;

    try {
      userRecord = await admin.auth().createUser({
        email,
        password,
        displayName: fullName,
        emailVerified: true,
      });
    } catch (error) {
      console.error("CREATE USER ERROR:", error);

      if (error.code === "auth/email-already-exists") {
        return res.status(409).json({
          success: false,
          message: "Email sudah digunakan.",
        });
      }

      return res.status(500).json({
        success: false,
        message: "Gagal membuat akun.",
      });
    }

    await db.collection("users").doc(userRecord.uid).set({
        uid: userRecord.uid,
        fullName,
        email,
        phoneNumber,
        isEmailVerified: true,
        nickname: "",
        avatarId: "assets/profile_pic/PP.png",
        status: "idle",
        currentRoomId: null,
        createdAt: new Date().toISOString(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await otpRef.set(
      {
        used: true,
        usedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return res.json({
      success: true,
      uid: userRecord.uid,
      message: "Akun berhasil dibuat.",
    });
  } catch (error) {
    console.error("VERIFY OTP ERROR:", error);

    return res.status(500).json({
      success: false,
      message: "Gagal memverifikasi OTP. Silakan coba lagi.",
    });
  }
});

const port = process.env.PORT || 5000;

app.listen(port, () => {
  console.log(`Moodly backend running on port ${port}`);
});