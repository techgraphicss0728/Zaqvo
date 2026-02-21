// import { CheckCircle } from 'lucide-react'
// import { Button } from '@/components/ui/button'

// export default function CTABanner() {
//     return (
//         <section className="bg-dark py-16 px-4 md:px-8 relative overflow-hidden">
//             {/* Decorative SVG water drop */}
//             <svg
//                 className="absolute right-0 top-0 h-full opacity-10"
//                 viewBox="0 0 200 400"
//                 xmlns="http://www.w3.org/2000/svg"
//             >
//                 <path
//                     fill="#257eb8"
//                     d="M100 0 C100 0 180 100 180 200 C180 310 100 400 100 400 C100 400 20 310 20 200 C20 100 100 0 100 0Z"
//                 />
//             </svg>
//             <div className="absolute -left-20 -bottom-20 w-64 h-64 rounded-full bg-primary/10" />

//             <div className="max-w-7xl mx-auto flex flex-col lg:flex-row items-center justify-between gap-8 relative z-10">
//                 {/* Text */}
//                 <div>
//                     <h2 className="text-3xl md:text-4xl font-extrabold text-white mb-6 max-w-xl leading-tight">
//                         Ready To Get Our Premium Water Delivery Service
//                     </h2>
//                     <ul className="space-y-3">
//                         {['Free Delivery on First Order', '7 Days a Week Service'].map((item) => (
//                             <li key={item} className="flex items-center gap-3 text-gray-300">
//                                 <CheckCircle className="w-5 h-5 text-primary flex-shrink-0" />
//                                 <span className="font-medium">{item}</span>
//                             </li>
//                         ))}
//                     </ul>
//                 </div>

//                 {/* Button */}
//                 <div className="flex-shrink-0">
//                     <Button size="lg" className="bg-primary hover:bg-primary/90 text-white font-bold px-10 py-4 text-lg shadow-lg shadow-primary/30">
//                         Our Services
//                     </Button>
//                 </div>
//             </div>
//         </section>
//     )
// }


import { CheckCircle, ArrowRight, Phone, Droplets } from 'lucide-react'
import { Button } from '@/components/ui/button'

const PHONE_NUMBER = '+917661002155'

export default function CTABanner() {
    return (
        <section className="relative py-20 px-4 md:px-8 overflow-hidden bg-[#0a1628]">

            {/* ── Animated water ripple rings ── */}
            <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                <div className="absolute w-[600px] h-[600px] rounded-full border border-[#257eb8]/10 animate-[ping_4s_ease-out_infinite]" />
                <div className="absolute w-[400px] h-[400px] rounded-full border border-[#257eb8]/15 animate-[ping_4s_ease-out_infinite_1s]" />
                <div className="absolute w-[200px] h-[200px] rounded-full border border-[#257eb8]/20 animate-[ping_4s_ease-out_infinite_2s]" />
            </div>

            {/* ── Mesh gradient blobs ── */}
            <div className="absolute -top-32 -left-32 w-[500px] h-[500px] rounded-full bg-[#257eb8]/10 blur-[120px] pointer-events-none" />
            <div className="absolute -bottom-32 -right-32 w-[400px] h-[400px] rounded-full bg-[#1a4f8a]/20 blur-[100px] pointer-events-none" />

            {/* ── Floating water drops (decorative) ── */}
            <Droplets className="absolute top-8 right-[15%] w-6 h-6 text-[#257eb8]/20 rotate-12" />
            <Droplets className="absolute bottom-10 left-[10%] w-4 h-4 text-[#257eb8]/15 -rotate-6" />
            <Droplets className="absolute top-1/2 right-8 w-5 h-5 text-[#257eb8]/10 rotate-45" />

            {/* ── Diagonal accent line ── */}
            <div className="absolute inset-0 overflow-hidden pointer-events-none">
                <div className="absolute top-0 right-[30%] w-px h-full bg-gradient-to-b from-transparent via-[#257eb8]/20 to-transparent" />
            </div>

            <div className="max-w-7xl mx-auto relative z-10">
                <div className="flex flex-col lg:flex-row items-center justify-between gap-10">

                    {/* ── Left: Text content ── */}
                    <div className="flex-1 text-center lg:text-left">

                        {/* Eyebrow label */}
                        <div className="inline-flex items-center gap-2 bg-[#257eb8]/10 border border-[#257eb8]/20 rounded-full px-4 py-1.5 mb-5">
                            <span className="w-2 h-2 rounded-full bg-[#257eb8] animate-pulse" />
                            <span className="text-[#257eb8] text-xs font-semibold tracking-widest uppercase">Limited Time Offer</span>
                        </div>

                        <h2 className="text-4xl md:text-5xl font-extrabold text-white mb-4 leading-[1.1] tracking-tight">
                            Ready To Get Our{' '}
                            <span className="relative inline-block">
                                <span className="relative z-10 text-[#257eb8]">Premium Water</span>
                                {/* Underline accent */}
                                <svg className="absolute -bottom-1 left-0 w-full" viewBox="0 0 200 8" preserveAspectRatio="none">
                                    <path d="M0 6 Q50 0 100 4 Q150 8 200 2" stroke="#257eb8" strokeWidth="2.5" fill="none" strokeLinecap="round" opacity="0.6" />
                                </svg>
                            </span>{' '}
                            Delivery Service?
                        </h2>

                        <p className="text-gray-400 text-base mb-6 max-w-md mx-auto lg:mx-0">
                            Join thousands of happy families who trust ZAQVO for clean, safe, and mineral-rich water every single day.
                        </p>

                        {/* Checklist */}
                        <ul className="flex flex-col sm:flex-row gap-3 sm:gap-6 justify-center lg:justify-start">
                            {[
                                'Free Delivery on First Order',
                                '7 Days a Week Service',
                                '100% Certified Pure'
                            ].map((item) => (
                                <li key={item} className="flex items-center gap-2 text-gray-300 text-sm">
                                    <CheckCircle className="w-4 h-4 text-[#257eb8] flex-shrink-0" />
                                    <span>{item}</span>
                                </li>
                            ))}
                        </ul>
                    </div>

                    {/* ── Right: CTA card ── */}
                    <div className="flex-shrink-0 w-full lg:w-auto">
                        <div className="bg-white/5 backdrop-blur-sm border border-white/10 rounded-2xl p-8 flex flex-col items-center gap-5 min-w-[280px]">

                            {/* Icon circle */}
                            <div className="w-16 h-16 rounded-full bg-[#257eb8]/20 border border-[#257eb8]/30 flex items-center justify-center">
                                <Phone className="w-7 h-7 text-[#257eb8]" />
                            </div>

                            <div className="text-center">
                                <p className="text-gray-400 text-xs uppercase tracking-widest mb-1">Call Us Anytime</p>
                                <p className="text-white font-bold text-xl">+91 76610 02155</p>
                            </div>

                            {/* Primary CTA */}
                            <a href={`tel:${PHONE_NUMBER}`} className="w-full">
                                <Button
                                    size="lg"
                                    className="w-full bg-[#257eb8] hover:bg-[#1e6a9e] text-white font-bold text-base px-8 py-5 rounded-xl shadow-lg shadow-[#257eb8]/30 group transition-all duration-300 hover:shadow-[#257eb8]/50 hover:scale-[1.02]"
                                >
                                    Book a Call
                                    <ArrowRight className="ml-2 w-4 h-4 group-hover:translate-x-1 transition-transform duration-300" />
                                </Button>
                            </a>

                            {/* Secondary CTA */}
                            <a href="#services" className="text-gray-400 hover:text-white text-sm font-medium underline underline-offset-4 transition-colors duration-200">
                                View Our Services →
                            </a>
                        </div>
                    </div>

                </div>
            </div>
        </section>
    )
}