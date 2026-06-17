/**
 * Super admin seed for MongoDB Atlas / Compass / mongosh
 *
 * Run AFTER the API has started once (roles collection must exist).
 *
 * 1. Open MongoDB Compass → your cluster → zaqvo database → Mongosh
 * 2. Paste the block below (edit mobile/name if needed)
 * 3. Login on dashboard with OTP only (no password)
 */

// --- UPDATE THESE ---
const MOBILE = "8340923044";
const NAME = "kamal";

const superRole = db.roles.findOne({ slug: "SUPER_ADMIN" });

if (!superRole) {
  print("ERROR: SUPER_ADMIN role not found. Start the backend once to seed roles.");
} else {
  db.admins.updateOne(
    { mobile_number: MOBILE },
    {
      $set: {
        name: NAME,
        mobile_number: MOBILE,
        otp_verified: true,
        is_active: true,
        is_super_admin: true,
        role_id: superRole._id.str(),
        role_slug: "SUPER_ADMIN",
        role_name: superRole.name,
        password_hash: null,
        updated_at: new Date(),
      },
      $setOnInsert: {
        created_by: null,
        last_login: null,
        created_at: new Date(),
      },
    },
    { upsert: true }
  );

  print("Super admin ready for OTP login:", MOBILE);
  printjson(db.admins.findOne({ mobile_number: MOBILE }));
}
