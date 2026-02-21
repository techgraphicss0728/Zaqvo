import { Linkedin, Facebook, Instagram } from "lucide-react";

import maheshImg from "@/assets/mahesh.jpg";
import manideepImg from "@/assets/manideep.jpg";
import naseerImg from "@/assets/naseer.jpg";
import tharunImg from "@/assets/tharun.jpg";

const team = [
    {
        name: "Mahesh",
        role: "Founder",
        image: maheshImg,
        socials: {
            facebook: "https://www.facebook.com/mahesh.thandu.923",
            linkedin:
                "https://www.linkedin.com/in/mahesh-thandu-b5205b349",
            instagram:
                "https://www.instagram.com/maheshh_1",
        },
    },
    {
        name: "Manideep",
        role: "Co-Founder",
        image: manideepImg,
        socials: {
            facebook:
                "https://www.facebook.com/profile.php?id=61588527268902",
            linkedin:
                "https://www.linkedin.com/in/manideep-netha-0741a6252",
            instagram:
                "https://www.instagram.com/manideep___netha",
        },
    },
    {
        name: "Naseer",
        role: "Marketing Head",
        image: naseerImg,
        socials: {
            linkedin:
                "https://www.linkedin.com/in/naseer-arman-8ab0732a8",
            instagram:
                "https://www.instagram.com/naseer_arman02",
        },
    },
    {
        name: "Tharun",
        role: "Operations Manager", // change if needed
        image: tharunImg,
        socials: {
            facebook: "https://www.facebook.com/tarun.vorsu",
            linkedin:
                "https://www.linkedin.com/in/v-tharun-kumar-0782493b2",
            instagram:
                "https://www.instagram.com/_.tarunkumar._05",
        },
    },
];

export default function Team() {
    return (
        <section className="py-20 px-4 md:px-8 bg-white">
            <div className="max-w-7xl mx-auto">

                <div className="text-center mb-14">
                    <span className="text-primary font-semibold text-sm tracking-widest uppercase">
                        Our Team
                    </span>
                    <h2 className="text-3xl md:text-4xl font-extrabold text-dark mt-2">
                        Meet Our Team
                    </h2>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
                    {team.map((member) => (
                        <div key={member.name} className="text-center group">

                            <div className="relative inline-block mb-5">
                                <img
                                    src={member.image}
                                    alt={member.name}
                                    className="w-44 h-44 rounded-full object-cover mx-auto border-4 border-gray-100 shadow-lg group-hover:border-primary transition"
                                />

                                {/* Hover Overlay */}
                                <div className="absolute inset-0 rounded-full bg-primary/80 flex items-center justify-center gap-4 opacity-0 group-hover:opacity-100 transition">

                                    {member.socials.linkedin && (
                                        <a href={member.socials.linkedin} target="_blank" rel="noreferrer">
                                            <Linkedin className="w-5 h-5 text-white hover:text-dark" />
                                        </a>
                                    )}

                                    {member.socials.facebook && (
                                        <a href={member.socials.facebook} target="_blank" rel="noreferrer">
                                            <Facebook className="w-5 h-5 text-white hover:text-dark" />
                                        </a>
                                    )}

                                    {member.socials.instagram && (
                                        <a href={member.socials.instagram} target="_blank" rel="noreferrer">
                                            <Instagram className="w-5 h-5 text-white hover:text-dark" />
                                        </a>
                                    )}

                                </div>
                            </div>

                            <h3 className="text-dark font-bold text-xl">{member.name}</h3>
                            <p className="text-primary font-medium text-sm mt-1">
                                {member.role}
                            </p>
                        </div>
                    ))}
                </div>

            </div>
        </section>
    );
}