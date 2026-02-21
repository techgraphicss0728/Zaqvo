import { ArrowRight, Calendar, User } from 'lucide-react'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'

const posts = [
    {
        image: 'https://placehold.co/400x250/257eb8/ffffff?text=Blog+Post+1',
        category: 'Health',
        title: 'Why Drinking Pure Water is Essential for Your Health',
        author: 'Dr. James Wilson',
        date: 'Jan 15, 2026',
        excerpt: 'Discover the profound impact that clean, purified water has on your overall health, energy levels, and longevity.',
    },
    {
        image: 'https://placehold.co/400x250/282e52/ffffff?text=Blog+Post+2',
        category: 'Technology',
        title: 'How Our 5-Stage Filtration System Works',
        author: 'Sarah Mitchell',
        date: 'Jan 22, 2026',
        excerpt: 'An in-depth look at the advanced technology behind our industry-leading water purification process.',
    },
    {
        image: 'https://placehold.co/400x250/257eb8/ffffff?text=Blog+Post+3',
        category: 'Tips',
        title: '10 Signs Your Home Needs a Water Purification System',
        author: 'Robert Kim',
        date: 'Feb 5, 2026',
        excerpt: 'Learn the warning signs that indicate your tap water may not be as safe as you think.',
    },
]

export default function Blog() {
    return (
        <section id="blog" className="py-20 px-4 md:px-8 bg-white">
            <div className="max-w-7xl mx-auto">
                <div className="text-center mb-14">
                    <span className="text-primary font-semibold text-sm tracking-widest uppercase">Our Blog</span>
                    <h2 className="text-3xl md:text-4xl font-extrabold text-dark mt-2">
                        Stay Updated with Zaqvo
                    </h2>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                    {posts.map((post) => (
                        <Card key={post.title} className="overflow-hidden group hover:shadow-xl transition-shadow duration-300">
                            <div className="overflow-hidden">
                                <img
                                    src={post.image}
                                    alt={post.title}
                                    className="w-full h-52 object-cover group-hover:scale-105 transition-transform duration-500"
                                />
                            </div>
                            <CardContent className="p-6">
                                <Badge className="mb-3 bg-primary/10 text-primary font-semibold text-xs">
                                    {post.category}
                                </Badge>
                                <h3 className="text-dark font-bold text-lg mb-3 leading-snug group-hover:text-primary transition-colors duration-200">
                                    {post.title}
                                </h3>
                                <div className="flex items-center gap-4 text-gray-400 text-xs mb-3">
                                    <span className="flex items-center gap-1">
                                        <User className="w-3 h-3" /> {post.author}
                                    </span>
                                    <span className="flex items-center gap-1">
                                        <Calendar className="w-3 h-3" /> {post.date}
                                    </span>
                                </div>
                                <p className="text-gray-500 text-sm mb-4 leading-relaxed">{post.excerpt}</p>
                                <a
                                    href="#"
                                    className="inline-flex items-center gap-1 text-primary font-semibold text-sm hover:gap-2 transition-all duration-200"
                                >
                                    Learn More <ArrowRight className="w-4 h-4" />
                                </a>
                            </CardContent>
                        </Card>
                    ))}
                </div>
            </div>
        </section>
    )
}
