import LegalLayout from "../components/LegalLayout";

export default function PrivacyPolicy() {
    return (
        <LegalLayout
            title="Zaqvo – Privacy Policy"
            date="22/02/2026"
        >
            <p>Zaqvo respects your privacy and is committed to protecting your personal data.</p>

            <h2 className="font-semibold text-lg">1. Information We Collect</h2>
            <ul className="list-disc ml-6">
                <li>Name, mobile number, and delivery address</li>
                <li>Payment transaction details (no card data stored)</li>
                <li>App usage data</li>
            </ul>

            <h2 className="font-semibold text-lg">2. Use of Information</h2>
            <p>Your information is used to:</p>
            <ul className="list-disc ml-6">
                <li>Process and deliver orders</li>
                <li>Provide support</li>
                <li>Improve service quality</li>
                <li>Send order updates</li>
            </ul>

            <h2 className="font-semibold text-lg">3. Data Sharing</h2>
            <ul className="list-disc ml-6">
                <li>Shared with delivery & plant partners for fulfillment</li>
                <li>We do NOT sell user data</li>
            </ul>

            <h2 className="font-semibold text-lg">4. Data Security</h2>
            <p>Reasonable safeguards are implemented. No platform guarantees 100% security.</p>

            <h2 className="font-semibold text-lg">5. User Rights</h2>
            <ul className="list-disc ml-6">
                <li>Update personal info</li>
                <li>Request account deletion</li>
            </ul>

            <h2 className="font-semibold text-lg">6. Cookies & Analytics</h2>
            <p>Used to improve app performance and user experience.</p>

            <h2 className="font-semibold text-lg">7. Policy Updates</h2>
            <p>Continued use implies acceptance of updates.</p>

            <h2 className="font-semibold text-lg">8. Contact</h2>
            <p>Email: support@zaqvo.com</p>
            <p>Phone: +91 76610 02155</p>
        </LegalLayout>
    );
}