import { Droplets, ShieldCheck, Filter, Heart } from 'lucide-react'

const features = [
    { icon: Droplets, label: 'Maximum Purity' },
    { icon: ShieldCheck, label: 'Chlorine Free' },
    { icon: Filter, label: '5 Steps Filtration' },
    { icon: Heart, label: 'Healthy Water' },
]

export default function Features() {
    return (
        <section className="bg-primary py-10">
            <div className="max-w-7xl mx-auto px-4 md:px-8">
                <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
                    {features.map(({ icon: Icon, label }) => (
                        <div
                            key={label}
                            className="flex flex-col items-center gap-3 group cursor-default"
                        >
                            <div className="w-16 h-16 rounded-full bg-white/15 flex items-center justify-center group-hover:bg-white/25 transition-colors duration-300">
                                <Icon className="w-8 h-8 text-white" />
                            </div>
                            <span className="text-white font-semibold text-sm md:text-base tracking-wide text-center">
                                {label}
                            </span>
                        </div>
                    ))}
                </div>
            </div>
        </section>
    )
}
