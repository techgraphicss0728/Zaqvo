import LegalLayout from "../components/LegalLayout";

export default function Terms() {
    return (
        <LegalLayout
            title="Zaqvo – Terms & Conditions"
            date="22/02/2026"
        >
            <p>
                Welcome to Zaqvo. These Terms & Conditions govern the use of the Zaqvo
                mobile application and services. By accessing or using the app, you
                agree to be bound by these terms.
            </p>

            <h2 className="font-semibold text-lg">1. About Zaqvo</h2>
            <p>
                Zaqvo is a packaged drinking water delivery service that supplies
                purified drinking water sourced from authorized water purification
                plants. The water is marketed, labeled, and delivered under the Zaqvo
                brand to residential and commercial customers.
            </p>

            <h2 className="font-semibold text-lg">2. Nature of Service</h2>
            <ul className="list-disc ml-6">
                <li>Water is procured from licensed and compliant treatment plants.</li>
                <li>Water is branded and labeled under Zaqvo.</li>
                <li>Pack sizes: 1L, 2L, 5L, 10L bottles and 20L cans.</li>
                <li>Delivery is handled at Zaqvo’s operational risk.</li>
            </ul>

            <h2 className="font-semibold text-lg">3. User Eligibility</h2>
            <ul className="list-disc ml-6">
                <li>Users must be 18 years or older.</li>
                <li>Users must provide accurate delivery information.</li>
            </ul>

            <h2 className="font-semibold text-lg">4. Ordering & Delivery</h2>
            <ul className="list-disc ml-6">
                <li>Orders are placed via the Zaqvo app.</li>
                <li>Delivery times are estimates and may vary.</li>
                <li>Zaqvo may refuse or cancel orders if service is unavailable.</li>
            </ul>

            <h2 className="font-semibold text-lg">5. Product Quality & Safety</h2>
            <ul className="list-disc ml-6">
                <li>Water is sourced from authorized purification plants.</li>
                <li>Water meets safety standards at dispatch.</li>
                <li>Quality complaints must be reported within 24 hours.</li>
                <li>Zaqvo is not responsible for improper storage after delivery.</li>
            </ul>

            <h2 className="font-semibold text-lg">6. Pricing & Payments</h2>
            <ul className="list-disc ml-6">
                <li>Prices include applicable taxes unless stated otherwise.</li>
                <li>Zaqvo may revise pricing or delivery charges.</li>
                <li>Payments are accepted via digital methods in the app.</li>
            </ul>

            <h2 className="font-semibold text-lg">7. Cancellation & Refunds</h2>
            <ul className="list-disc ml-6">
                <li>Orders may be canceled before dispatch.</li>
                <li>Cancellations after dispatch are not guaranteed.</li>
                <li>Refunds are processed within 5–7 working days.</li>
                <li>No refunds for incorrect address or refusal.</li>
            </ul>

            <h2 className="font-semibold text-lg">8. Customer Responsibilities</h2>
            <ul className="list-disc ml-6">
                <li>Provide accurate address and contact details.</li>
                <li>Be available at the delivery location.</li>
                <li>Handle 20L cans carefully after delivery.</li>
                <li>Do not misuse or resell products unlawfully.</li>
            </ul>

            <h2 className="font-semibold text-lg">9. Branding & Labeling Disclaimer</h2>
            <p>
                Zaqvo branding represents marketing and distribution. Water is sourced
                from third-party purification plants compliant with regulations. Zaqvo
                does not claim ownership of purification infrastructure unless stated.
            </p>

            <h2 className="font-semibold text-lg">10. Limitation of Liability</h2>
            <p>
                Zaqvo is not liable for indirect or consequential damages. Liability, if
                any, is limited to the value of the delivered product.
            </p>

            <h2 className="font-semibold text-lg">11. Suspension or Termination</h2>
            <ul className="list-disc ml-6">
                <li>Fraudulent activity</li>
                <li>Abuse of service</li>
                <li>Violation of terms</li>
            </ul>

            <h2 className="font-semibold text-lg">12. Governing Law</h2>
            <p>
                These Terms are governed by the laws of India. Courts of competent
                jurisdiction in India shall have exclusive authority.
            </p>

            <h2 className="font-semibold text-lg">13. Contact Information</h2>
            <p>Email: support@zaqvo.com</p>
            <p>Phone: +91 76610 02155</p>
        </LegalLayout>
    );
}