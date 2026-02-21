import { Home, Factory, Building2, Waves } from 'lucide-react'
import servicesImg from '@/assets/services.png'

const services = [
    {
        icon: Home,
        title: 'Residential Waters',
        description: 'Complete home water purification systems designed to give your family the cleanest, safest drinking water possible.',
    },
    {
        icon: Factory,
        title: 'Filtration Plants',
        description: 'Industrial-grade filtration plants for large-scale water treatment needs, built for reliability and efficiency.',
    },
    {
        icon: Building2,
        title: 'Commercial Waters',
        description: 'Tailored water solutions for offices, restaurants, and commercial establishments of all sizes.',
    },
    {
        icon: Waves,
        title: 'Water Softening',
        description: 'Advanced water softening systems that eliminate hard water minerals, protecting your appliances and skin.',
    },
]

export default function Services() {
    return (
        <section id="services" className="py-20 px-4 md:px-8 bg-gray-50">
            <div className="max-w-7xl mx-auto">
                {/* Heading */}
                <div className="text-center mb-14">
                    <span className="text-primary font-semibold text-sm tracking-widest uppercase">Our Services</span>
                    <h2 className="text-3xl md:text-4xl font-extrabold text-dark mt-2 max-w-2xl mx-auto leading-tight">
                        Protect Your Family with Best Water Filtering System Services
                    </h2>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
                    {/* Image */}
                    <div className="relative order-2 lg:order-1">
                        <div className="absolute inset-0 bg-primary/10 rounded-2xl transform rotate-3" />
                        <img
                            src={servicesImg}
                            alt="Water Services"
                            className="w-full rounded-2xl shadow-xl relative z-10 object-cover"
                        />
                    </div>

                    {/* Service Items */}
                    <div className="order-1 lg:order-2 space-y-6">
                        {services.map(({ icon: Icon, title, description }) => (
                            <div
                                key={title}
                                className="flex gap-5 p-5 bg-white rounded-xl shadow-sm hover:shadow-md transition-shadow duration-300 group"
                            >
                                <div className="flex-shrink-0 w-14 h-14 rounded-xl bg-primary/10 flex items-center justify-center group-hover:bg-primary transition-colors duration-300">
                                    <Icon className="w-7 h-7 text-primary group-hover:text-white transition-colors duration-300" />
                                </div>
                                <div>
                                    <h3 className="text-dark font-bold text-lg mb-1">{title}</h3>
                                    <p className="text-gray-500 text-sm leading-relaxed">{description}</p>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </section>
    )
}