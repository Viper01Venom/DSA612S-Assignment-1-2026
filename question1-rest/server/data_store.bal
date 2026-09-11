
import ballerina/time;

map<Asset> assetStore = {};

map<Institution> institutionStore = {};

function generateId(string prefix) returns string {
    time:Utc now = time:utcNow();
    int timestamp = now[0];
    return prefix + "-" + timestamp.toString();
}

function initSampleData() {
    
    institutionStore["Namibia University of Science and Technology"] = {
        name: "Namibia University of Science and Technology",
        abbreviation: "NUST",
        sites: ["Main Campus - Innovation Lab", "Main Campus - Library", "Khomasdal Campus"]
    };
    institutionStore["University of Namibia"] = {
        name: "University of Namibia",
        abbreviation: "UNAM",
        sites: ["Main Campus - Library", "Oshakati Campus", "Keetmanshoop Campus"]
    };
    institutionStore["International University of Management"] = {
        name: "International University of Management",
        abbreviation: "IUM",
        sites: ["Windhoek Campus - Library", "Walvis Bay Campus"]
    };

    assetStore["NUST-LIB-3DP-001"] = {
        assetTag: "NUST-LIB-3DP-001",
        name: "Pro-Series 3D Printer",
        description: "High-precision laboratory printer for simulation and prototype development.",
        institution: "Namibia University of Science and Technology",
        site: "Main Campus - Innovation Lab",
        status: "AVAILABLE",
        dateAcquired: "2024-03-10",
        components: [
            {compId: "C101", name: "High-Torque Stepper Motor", description: "Main motor for X-axis movement."},
            {compId: "C102", name: "Heated Build Plate", description: "Glass plate with heating element for print adhesion."}
        ],
        schedules: [
            {scheduleId: "SCH-882", 'type: "MAINTENANCE", dueDate: "2026-09-01", description: "Quarterly calibration and nozzle cleaning."}
        ],
        workOrders: [
            {
                orderId: "WO-554",
                status: "OPEN",
                description: "Nozzle heat-bed failure",
                tasks: [
                    {taskId: "T1", description: "Check thermal sensor connectivity."},
                    {taskId: "T2", description: "Replace heating element if faulty."}
                ]
            }
        ]
    };

    assetStore["UNAM-LIB-LPT-001"] = {
        assetTag: "UNAM-LIB-LPT-001",
        name: "Dell Latitude 5540 Laptop",
        description: "Student loan laptop with i5 processor and 16GB RAM.",
        institution: "University of Namibia",
        site: "Main Campus - Library",
        status: "LOANED_OUT",
        dateAcquired: "2023-08-15",
        components: [
            {compId: "C201", name: "65W USB-C Charger", description: "Original Dell power adapter."},
            {compId: "C202", name: "Laptop Bag", description: "Protective carry case."}
        ],
        schedules: [
            {scheduleId: "SCH-201", 'type: "MAINTENANCE", dueDate: "2026-06-15", description: "Annual hardware inspection and OS update."}
        ],
        workOrders: []
    };

    assetStore["NUST-LIB-MR-001"] = {
        assetTag: "NUST-LIB-MR-001",
        name: "Innovation Lab Meeting Room A",
        description: "20-seater meeting room with projector and whiteboard.",
        institution: "Namibia University of Science and Technology",
        site: "Main Campus - Innovation Lab",
        status: "AVAILABLE",
        dateAcquired: "2022-01-10",
        components: [
            {compId: "C301", name: "Epson Projector", description: "Ceiling-mounted HD projector."},
            {compId: "C302", name: "Conference Phone", description: "Polycom conference speaker system."}
        ],
        schedules: [
            {scheduleId: "SCH-301", 'type: "BOOKING", dueDate: "2026-09-05", description: "Faculty board meeting."}
        ],
        workOrders: []
    };

    assetStore["UNAM-OSH-BK-001"] = {
        assetTag: "UNAM-OSH-BK-001",
        name: "Data Structures and Algorithms in Java",
        description: "Textbook by Robert Lafore, 2nd Edition.",
        institution: "University of Namibia",
        site: "Oshakati Campus",
        status: "AVAILABLE",
        dateAcquired: "2021-02-20",
        components: [],
        schedules: [],
        workOrders: []
    };

    assetStore["IUM-WHK-TC-001"] = {
        assetTag: "IUM-WHK-TC-001",
        name: "HP t640 Thin Client",
        description: "Thin client terminal for computer lab access.",
        institution: "International University of Management",
        site: "Windhoek Campus - Library",
        status: "UNDER_MAINTENANCE",
        dateAcquired: "2023-11-01",
        components: [
            {compId: "C501", name: "Monitor", description: "24-inch HP LED monitor."},
            {compId: "C502", name: "Keyboard & Mouse Set", description: "HP wired USB peripherals."}
        ],
        schedules: [
            {scheduleId: "SCH-501", 'type: "MAINTENANCE", dueDate: "2026-08-01", description: "Firmware update and hardware diagnostics."}
        ],
        workOrders: [
            {
                orderId: "WO-801",
                status: "IN_PROGRESS",
                description: "Display port not outputting video",
                tasks: [
                    {taskId: "T10", description: "Test with alternate cable."},
                    {taskId: "T11", description: "Check GPU driver on thin client firmware."}
                ]
            }
        ]
    };

    assetStore["NUST-KHO-LAB-001"] = {
        assetTag: "NUST-KHO-LAB-001",
        name: "Computer Lab B2",
        description: "40-seat computer laboratory with thin client workstations.",
        institution: "Namibia University of Science and Technology",
        site: "Khomasdal Campus",
        status: "AVAILABLE",
        dateAcquired: "2022-06-15",
        components: [],
        schedules: [
            {scheduleId: "SCH-601", 'type: "BOOKING", dueDate: "2026-09-10", description: "DSA612S practical exam."},
            {scheduleId: "SCH-602", 'type: "MAINTENANCE", dueDate: "2026-07-20", description: "Bi-annual network and workstation maintenance."}
        ],
        workOrders: []
    };
}
