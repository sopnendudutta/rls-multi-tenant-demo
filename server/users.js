const USERS = {
    priya: {
        id: "priya",
        name: "Nurse Priya",
        role: "VIEWER",
        orgId: "supra",
        department: "ortho",
        ceiling: 10,
        clearance: "",
        description: "Ortho viewer, ward-level access, no compliance clearance",
    },

    vikram: {
        id: "vikram",
        name: "Dr. Vikram",
        role: "HOD",
        orgId: "supra",
        department: "ortho",
        ceiling: 4,
        clearance: "",
        description: "Ortho HOD, bypasses hierarchy ceiling, no MNPI clearance",
    },

    suresh: {
        id: "suresh",
        name: "Admin Suresh",
        role: "ADMIN",
        orgId: "supra",
        department: "admin",
        ceiling: 1,
        clearance: "MNPI,CONFIDENTIAL,CONTROLLED_SUBSTANCE",
        description: "Supra admin with full compliance clearance",
    },

    ananya: {
        id: "ananya",
        name: "Dr. Ananya",
        role: "EDITOR",
        orgId: "supra",
        department: "medicine",
        ceiling: 8,
        clearance: "",
        description: "Medicine editor, no compliance clearance",
    },

    cityDoctor: {
        id: "cityDoctor",
        name: "City Clinic Doctor",
        role: "EDITOR",
        orgId: "city_clinic",
        department: "medicine",
        ceiling: 8,
        clearance: "",
        description: "City Clinic doctor, must see zero Supra rows",
    },

    ravi: {
        id: "ravi",
        name: "Pharmacist Ravi",
        role: "VIEWER",
        orgId: "supra",
        department: "pharmacy",
        ceiling: 12,
        clearance: "CONTROLLED_SUBSTANCE",
        description: "Surprise-style pharmacy user with controlled substance clearance",
    },
};

module.exports = { USERS };