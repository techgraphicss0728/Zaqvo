import { Phone } from 'lucide-react'

export default function ContactCTABar() {
    return (
        <section id="contact" className="bg-primary py-10 px-4">
            <div className="max-w-7xl mx-auto text-center">
                <p className="text-white/90 text-base font-medium mb-2">
                    Please Call Us to Take an Extraordinary Service
                </p>
                <a
                    href="tel:+18005551234"
                    className="inline-flex items-center gap-3 text-white font-extrabold text-3xl md:text-4xl hover:text-dark transition-colors duration-200"
                >
                    <Phone className="w-8 h-8" />
                    +1 (800) 555-1234
                </a>
            </div>
        </section>
    )
}
