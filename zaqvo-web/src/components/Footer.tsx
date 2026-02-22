import { Link } from 'react-router-dom'
import logoImg from '@/assets/LOGO_ZAQVO.png'
import { MapPin, Phone, Mail, Clock, Facebook, Instagram, Linkedin } from 'lucide-react'

const SOCIAL_LINKS = [
    { Icon: Facebook, href: 'https://www.facebook.com/share/1CA9AF2w28/', label: 'Facebook' },
    { Icon: Instagram, href: 'https://www.instagram.com/zaqvo_water?igsh=MXdvdW1zcHYyM2J5bg==', label: 'Instagram' },
    { Icon: Linkedin, href: 'https://www.linkedin.com/in/zaqvo-water-66b8973b2?utm_source=share_via&utm_content=profile&utm_medium=member_android', label: 'LinkedIn' },
]


export default function Footer() {

    return (
        <footer className="bg-white text-gray-600 border-t border-gray-100">
            {/* Main Footer */}
            <div className="max-w-7xl mx-auto px-4 md:px-8 py-16 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-2 gap-10">
                {/* Column 1: Logo + Tagline + Hours */}
                <div>
                    <Link to="/" className="inline-flex items-center mb-3">
                        <img src={logoImg} alt="Zaqvo" className="h-10 w-auto object-contain" />
                    </Link>
                    <p className="text-gray-500 text-sm leading-relaxed mb-5">
                        Delivering pure, clean water solutions for healthier homes and businesses since 2025.
                    </p>
                    <div className="flex items-start gap-2 text-sm">
                        <Clock className="w-4 h-4 text-primary mt-0.5 flex-shrink-0" />
                        <div>
                            <div className="text-dark font-medium">Open Hours</div>
                            <div className="text-gray-500">Mon–Fri: 5:30am – 11:30pm</div>
                            <div className="text-gray-500">Sat–Sun: 5:30am – 11:30pm</div>
                        </div>
                    </div>
                    {/* Social Icons */}
                    <div className="flex gap-3 mt-5">
                        {SOCIAL_LINKS.map(({ Icon, href, label }) => (
                            <a
                                key={label}
                                href={href}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="w-9 h-9 rounded-full bg-gray-100 flex items-center justify-center hover:bg-primary transition-colors duration-200"
                                aria-label={label}
                            >
                                <Icon className="w-4 h-4 text-dark group-hover:text-white" />
                            </a>
                        ))}
                    </div>
                </div>

                {/*  */}
                <div>
                    <h3 className="text-dark font-bold text-lg mb-5">Contact Info</h3>
                    <ul className="space-y-4 text-sm">
                        <li className="flex items-start gap-3">
                            <MapPin className="w-4 h-4 text-primary mt-0.5 flex-shrink-0" />
                            <span>YusafGuda, Hyderabad</span>
                        </li>
                        <li className="flex items-center gap-3">
                            <Phone className="w-4 h-4 text-primary flex-shrink-0" />
                            <a href="tel:+917661002155" className="hover:text-primary transition-colors">+91 76610 02155</a>
                        </li>
                        <li className="flex items-center gap-3">
                            <Mail className="w-4 h-4 text-primary flex-shrink-0" />
                            <a href="mailto:support@zaqvo.com" className="hover:text-primary transition-colors">support@zaqvo.com</a>
                        </li>
                    </ul>
                </div>
            </div>

            {/* Bottom Bar */}
            <div className="border-t border-gray-200">
                <div className="max-w-7xl mx-auto px-4 md:px-8 py-5 flex flex-col items-center gap-3 text-sm text-gray-400">
                    <span className="text-center">© 2026 Zaqvo. Design & developed by <a href="https://techgraphicss.com" target="_blank" rel="noopener noreferrer" className="font-bold text-blue-600 hover:text-blue-700 transition-colors">techgraphicss.com</a></span>
                    <div className="flex gap-5">
                        <a href="/terms" className="hover:text-primary transition-colors">Terms of Service</a>
                        <a href="/privacy" className="hover:text-primary transition-colors">Privacy Policy</a>
                    </div>
                </div>
            </div>
        </footer>
    )
}
