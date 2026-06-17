"""MongoDB OTP records — purpose labels and collection name."""
from typing import Literal

OtpPurpose = Literal["signup", "login", "provision"]

OTPS_COLLECTION = "otps"
