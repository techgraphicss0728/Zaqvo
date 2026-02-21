import { TrendingUp, Target, CheckCircle } from 'lucide-react'
import chooseUsImg from '@/assets/chooseUs.png'

const features = [
    {
        icon: TrendingUp,
        title: 'Content Marketing',
        description: 'We create compelling content that educates your customers about the importance of clean water and our solutions.',
    },
    {
        icon: Target,
        title: 'Marketing Strategy',
        description: 'Our proven strategies help us reach families who need clean water solutions, building lasting relationships.',
    },
]

export default function WhyChooseUs() {
    return (
        <section className="py-20 px-4 md:px-8 bg-white">
            <div className="max-w-7xl mx-auto grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
                {/* Content */}
                <div>
                    <span className="text-primary font-semibold text-sm tracking-widest uppercase">Why Choose Us</span>
                    <h2 className="text-3xl md:text-4xl font-extrabold text-dark mt-2 mb-8 leading-tight">
                        Protect Your Family with One of The Best Water Filtering System
                    </h2>

                    <div className="space-y-6 mb-8">
                        {features.map(({ icon: Icon, title, description }) => (
                            <div key={title} className="flex gap-5 group">
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

                    {/* Checklist */}
                    <ul className="space-y-3">
                        {['100% Natural & Pure Water', 'Certified Filtration Technology', 'Eco-Friendly Process', '24/7 Customer Support'].map((item) => (
                            <li key={item} className="flex items-center gap-3 text-gray-600 text-sm">
                                <CheckCircle className="w-5 h-5 text-primary flex-shrink-0" />
                                {item}
                            </li>
                        ))}
                    </ul>
                </div>

                {/* Image */}
                <div className="relative">
                    <div className="absolute -bottom-4 -right-4 w-full h-full border-2 border-primary/20 rounded-2xl" />
                    <img
                        src={chooseUsImg}
                        alt="Why Choose Zaqvo"
                        className="w-full rounded-2xl shadow-xl relative z-10 object-cover"
                    />
                </div>
            </div>
        </section>
    )
}