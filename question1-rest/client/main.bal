import ballerina/http;
import ballerina/io;

final http:Client apiClient = check new ("http://localhost:9090/api");

public function main() returns error? {
    io:println("");
    io:println("╔══════════════════════════════════════════════════════════╗");
    io:println("║      Library Management System - CLI Client              ║");
    io:println("║      Ministry of Higher Education, Training              ║");
    io:println("║      and Innovations                                     ║");
    io:println("╚══════════════════════════════════════════════════════════╝");
    io:println("");

    boolean running = true;
    while running {
        displayMainMenu();
        string choice = io:readln("Enter your choice: ");

        match choice {
            "1" => { check viewAllAssets(); }
            "2" => { check viewAssetsByInstitution(); }
            "3" => { check viewAssetsBySite(); }
            "4" => { check lookupAsset(); }
            "5" => { check createAsset(); }
            "6" => { check updateAsset(); }
            "7" => { check deleteAsset(); }
            "8" => { check loanAsset(); }
            "9" => { check bookAsset(); }
            "10" => { check returnAsset(); }
            "11" => { check viewOverdueAssets(); }
            "12" => { check addSchedule(); }
            "13" => { check removeSchedule(); }
            "14" => { check addComponent(); }
            "15" => { check removeComponent(); }
            "16" => { check openWorkOrder(); }
            "17" => { check updateWorkOrder(); }
            "18" => { check closeWorkOrder(); }
            "19" => { check listInstitutions(); }
            "20" => { check addInstitution(); }
            "21" => { check removeInstitution(); }
            "0" => {
                io:println("\nGoodbye! Thank you for using the Library Management System.\n");
                running = false;
            }
            _ => {
                io:println("\n⚠ Invalid choice. Please enter a number from the menu.\n");
            }
        }
    }
}

function displayMainMenu() {
    io:println("┌──────────────────────────────────────────────────────────┐");
    io:println("│                    MAIN MENU                             │");
    io:println("├──────────────────────────────────────────────────────────┤");
    io:println("│  GLOBAL VIEW                                             │");
    io:println("│   1.  View all assets                                    │");
    io:println("│   2.  View assets by institution                         │");
    io:println("│   3.  View assets by institution and site                │");
    io:println("│   4.  Look up a specific asset                           │");
    io:println("├──────────────────────────────────────────────────────────┤");
    io:println("│  ASSET MANAGEMENT                                        │");
    io:println("│   5.  Create a new asset                                 │");
    io:println("│   6.  Update an existing asset                           │");
    io:println("│   7.  Delete an asset                                    │");
    io:println("├──────────────────────────────────────────────────────────┤");
    io:println("│  LOANING & BOOKING                                       │");
    io:println("│   8.  Loan an asset                                      │");
    io:println("│   9.  Book a meeting room/lab                            │");
    io:println("│  10.  Return a loaned/booked asset                       │");
    io:println("├──────────────────────────────────────────────────────────┤");
    io:println("│  OVERDUE DASHBOARD                                       │");
    io:println("│  11.  View overdue maintenance items                     │");
    io:println("├──────────────────────────────────────────────────────────┤");
    io:println("│  SCHEDULE MANAGER                                        │");
    io:println("│  12.  Add a schedule to an asset                         │");
    io:println("│  13.  Remove a schedule from an asset                    │");
    io:println("├──────────────────────────────────────────────────────────┤");
    io:println("│  COMPONENT MANAGEMENT                                    │");
    io:println("│  14.  Add a component to an asset                        │");
    io:println("│  15.  Remove a component from an asset                   │");
    io:println("├──────────────────────────────────────────────────────────┤");
    io:println("│  WORK ORDERS                                             │");
    io:println("│  16.  Open a new work order                              │");
    io:println("│  17.  Update an existing work order                      │");
    io:println("│  18.  Close/remove a work order                          │");
    io:println("├──────────────────────────────────────────────────────────┤");
    io:println("│  INSTITUTION MANAGEMENT                                  │");
    io:println("│  19.  List all institutions                              │");
    io:println("│  20.  Add a new institution                              │");
    io:println("│  21.  Remove an institution                              │");
    io:println("├──────────────────────────────────────────────────────────┤");
    io:println("│   0.  Exit                                               │");
    io:println("└──────────────────────────────────────────────────────────┘");
}

function viewAllAssets() returns error? {
    io:println("\n─── ALL ASSETS (Global View) ───────────────────────────────");
    json response = check apiClient->get("/assets");
    json[] assets = <json[]>response;

    if assets.length() == 0 {
        io:println("  No assets found.");
    } else {
        foreach var asset in assets {
            printAssetSummary(asset);
        }
        io:println("  Total assets: " + assets.length().toString());
    }
    io:println("");
}

function viewAssetsByInstitution() returns error? {
    string institution = io:readln("Enter institution name: ");
    io:println("\n─── ASSETS FOR: " + institution + " ─────────────────────────");

    string encodedInst = institution;
    json response = check apiClient->get("/assets?institution=" + encodedInst);
    json[] assets = <json[]>response;

    if assets.length() == 0 {
        io:println("  No assets found for this institution.");
    } else {
        foreach var asset in assets {
            printAssetSummary(asset);
        }
        io:println("  Total: " + assets.length().toString() + " assets");
    }
    io:println("");
}

function viewAssetsBySite() returns error? {
    string institution = io:readln("Enter institution name: ");
    string site = io:readln("Enter site/campus name: ");
    io:println("\n─── ASSETS AT: " + institution + " > " + site + " ──────────");

    json response = check apiClient->get("/assets?institution=" + institution + "&site=" + site);
    json[] assets = <json[]>response;

    if assets.length() == 0 {
        io:println("  No assets found for this institution/site.");
    } else {
        foreach var asset in assets {
            printAssetSummary(asset);
        }
        io:println("  Total: " + assets.length().toString() + " assets");
    }
    io:println("");
}

function lookupAsset() returns error? {
    string assetTag = io:readln("Enter asset tag: ");
    io:println("\n─── ASSET DETAILS ──────────────────────────────────────────");

    json|error response = apiClient->get("/assets/" + assetTag);
    if response is error {
        io:println("  ✗ Asset '" + assetTag + "' not found.");
    } else {
        printAssetDetails(response);
    }
    io:println("");
}

function createAsset() returns error? {
    io:println("\n─── CREATE NEW ASSET ───────────────────────────────────────");
    string assetTag = io:readln("  Asset tag (unique ID): ");
    string name = io:readln("  Name: ");
    string description = io:readln("  Description: ");
    string institution = io:readln("  Institution: ");
    string site = io:readln("  Site/Campus: ");
    string dateAcquired = io:readln("  Date acquired (YYYY-MM-DD): ");

    json payload = {
        "assetTag": assetTag,
        "name": name,
        "description": description,
        "institution": institution,
        "site": site,
        "status": "AVAILABLE",
        "dateAcquired": dateAcquired,
        "components": [],
        "schedules": [],
        "workOrders": []
    };

    json|error response = apiClient->post("/assets", payload);
    if response is error {
        io:println("  ✗ Failed to create asset: " + response.message());
    } else {
        io:println("  ✓ Asset '" + assetTag + "' created successfully!");
    }
    io:println("");
}

function updateAsset() returns error? {
    io:println("\n─── UPDATE ASSET ───────────────────────────────────────────");
    string assetTag = io:readln("  Asset tag to update: ");

    json|error current = apiClient->get("/assets/" + assetTag);
    if current is error {
        io:println("  ✗ Asset '" + assetTag + "' not found.");
        return;
    }

    io:println("  (Press Enter to keep current value)");
    string name = io:readln("  Name [" + (check current.name).toString() + "]: ");
    string description = io:readln("  Description [" + (check current.description).toString() + "]: ");
    string status = io:readln("  Status (AVAILABLE/LOANED_OUT/OCCUPIED/UNDER_MAINTENANCE/DISPOSED) [" + (check current.status).toString() + "]: ");

    json payload = {
        "assetTag": assetTag,
        "name": name == "" ? check current.name : name,
        "description": description == "" ? check current.description : description,
        "institution": check current.institution,
        "site": check current.site,
        "status": status == "" ? check current.status : status,
        "dateAcquired": check current.dateAcquired,
        "components": check current.components,
        "schedules": check current.schedules,
        "workOrders": check current.workOrders
    };

    json|error response = apiClient->put("/assets/" + assetTag, payload);
    if response is error {
        io:println("  ✗ Failed to update asset: " + response.message());
    } else {
        io:println("  ✓ Asset '" + assetTag + "' updated successfully!");
    }
    io:println("");
}

function deleteAsset() returns error? {
    io:println("\n─── DELETE ASSET ───────────────────────────────────────────");
    string assetTag = io:readln("  Asset tag to delete: ");
    string confirm = io:readln("  Are you sure? (yes/no): ");

    if confirm == "yes" {
        json|error response = apiClient->delete("/assets/" + assetTag);
        if response is error {
            io:println("  ✗ Failed to delete asset: " + response.message());
        } else {
            io:println("  ✓ Asset '" + assetTag + "' deleted successfully!");
        }
    } else {
        io:println("  Deletion cancelled.");
    }
    io:println("");
}

function loanAsset() returns error? {
    io:println("\n─── LOAN AN ASSET ─────────────────────────────────────────");
    string assetTag = io:readln("  Asset tag to loan: ");
    string borrower = io:readln("  Borrower name: ");
    string returnDate = io:readln("  Return date (YYYY-MM-DD): ");

    json payload = {
        "borrower": borrower,
        "returnDate": returnDate
    };

    json|error response = apiClient->post("/assets/" + assetTag + "/loan", payload);
    if response is error {
        io:println("  ✗ Failed to loan asset: " + response.message());
    } else {
        io:println("  ✓ Asset '" + assetTag + "' loaned to '" + borrower + "' successfully!");
        io:println("    Return by: " + returnDate);
    }
    io:println("");
}

function bookAsset() returns error? {
    io:println("\n─── BOOK A MEETING ROOM / LAB ─────────────────────────────");
    string assetTag = io:readln("  Asset tag to book: ");
    string bookedBy = io:readln("  Your name: ");
    string date = io:readln("  Booking date (YYYY-MM-DD): ");
    string startTime = io:readln("  Start time (HH:MM): ");
    string endTime = io:readln("  End time (HH:MM): ");
    string purpose = io:readln("  Purpose: ");

    json payload = {
        "bookedBy": bookedBy,
        "date": date,
        "startTime": startTime,
        "endTime": endTime,
        "purpose": purpose
    };

    json|error response = apiClient->post("/assets/" + assetTag + "/book", payload);
    if response is error {
        io:println("  ✗ Failed to book asset: " + response.message());
    } else {
        io:println("  ✓ Asset '" + assetTag + "' booked successfully!");
        io:println("    Date: " + date + " | Time: " + startTime + " - " + endTime);
    }
    io:println("");
}

function returnAsset() returns error? {
    io:println("\n─── RETURN AN ASSET ───────────────────────────────────────");
    string assetTag = io:readln("  Asset tag to return: ");

    json|error response = apiClient->post("/assets/" + assetTag + "/return", ());
    if response is error {
        io:println("  ✗ Failed to return asset: " + response.message());
    } else {
        io:println("  ✓ Asset '" + assetTag + "' returned successfully! Status set to AVAILABLE.");
    }
    io:println("");
}

function viewOverdueAssets() returns error? {
    io:println("\n─── OVERDUE DASHBOARD ─────────────────────────────────────");
    json response = check apiClient->get("/assets/overdue");
    json[] assets = <json[]>response;

    if assets.length() == 0 {
        io:println("  ✓ No overdue maintenance items found. All clear!");
    } else {
        io:println("  ⚠ " + assets.length().toString() + " asset(s) with overdue maintenance:\n");
        foreach var asset in assets {
            printAssetSummary(asset);
            
            json[] schedules = <json[]>(check asset.schedules);
            foreach var sched in schedules {
                string schedType = (check sched.'type).toString();
                if schedType == "MAINTENANCE" {
                    io:println("      ⏰ Due: " + (check sched.dueDate).toString() + " - " + (check sched.description).toString());
                }
            }
        }
    }
    io:println("");
}

function addSchedule() returns error? {
    io:println("\n─── ADD SCHEDULE ───────────────────────────────────────────");
    string assetTag = io:readln("  Asset tag: ");
    string scheduleId = io:readln("  Schedule ID: ");
    string schedType = io:readln("  Type (MAINTENANCE/BOOKING): ");
    string dueDate = io:readln("  Due date (YYYY-MM-DD): ");
    string description = io:readln("  Description: ");

    json payload = {
        "scheduleId": scheduleId,
        "type": schedType,
        "dueDate": dueDate,
        "description": description
    };

    json|error response = apiClient->post("/assets/" + assetTag + "/schedules", payload);
    if response is error {
        io:println("  ✗ Failed to add schedule: " + response.message());
    } else {
        io:println("  ✓ Schedule '" + scheduleId + "' added to asset '" + assetTag + "'!");
    }
    io:println("");
}

function removeSchedule() returns error? {
    io:println("\n─── REMOVE SCHEDULE ───────────────────────────────────────");
    string assetTag = io:readln("  Asset tag: ");
    string scheduleId = io:readln("  Schedule ID to remove: ");

    json|error response = apiClient->delete("/assets/" + assetTag + "/schedules/" + scheduleId);
    if response is error {
        io:println("  ✗ Failed to remove schedule: " + response.message());
    } else {
        io:println("  ✓ Schedule '" + scheduleId + "' removed from asset '" + assetTag + "'!");
    }
    io:println("");
}

function addComponent() returns error? {
    io:println("\n─── ADD COMPONENT ─────────────────────────────────────────");
    string assetTag = io:readln("  Asset tag: ");
    string compId = io:readln("  Component ID: ");
    string name = io:readln("  Component name: ");
    string description = io:readln("  Description: ");

    json payload = {
        "compId": compId,
        "name": name,
        "description": description
    };

    json|error response = apiClient->post("/assets/" + assetTag + "/components", payload);
    if response is error {
        io:println("  ✗ Failed to add component: " + response.message());
    } else {
        io:println("  ✓ Component '" + compId + "' added to asset '" + assetTag + "'!");
    }
    io:println("");
}

function removeComponent() returns error? {
    io:println("\n─── REMOVE COMPONENT ──────────────────────────────────────");
    string assetTag = io:readln("  Asset tag: ");
    string compId = io:readln("  Component ID to remove: ");

    json|error response = apiClient->delete("/assets/" + assetTag + "/components/" + compId);
    if response is error {
        io:println("  ✗ Failed to remove component: " + response.message());
    } else {
        io:println("  ✓ Component '" + compId + "' removed from asset '" + assetTag + "'!");
    }
    io:println("");
}

function openWorkOrder() returns error? {
    io:println("\n─── OPEN WORK ORDER ───────────────────────────────────────");
    string assetTag = io:readln("  Asset tag: ");
    string orderId = io:readln("  Work order ID: ");
    string description = io:readln("  Description of issue: ");

    json[] tasks = [];
    io:println("  Add tasks (type 'done' when finished):");
    int taskNum = 1;
    while true {
        string taskDesc = io:readln("    Task " + taskNum.toString() + " description (or 'done'): ");
        if taskDesc == "done" {
            break;
        }
        tasks.push({
            "taskId": "T" + taskNum.toString(),
            "description": taskDesc
        });
        taskNum = taskNum + 1;
    }

    json payload = {
        "orderId": orderId,
        "status": "OPEN",
        "description": description,
        "tasks": tasks
    };

    json|error response = apiClient->post("/assets/" + assetTag + "/workorders", payload);
    if response is error {
        io:println("  ✗ Failed to open work order: " + response.message());
    } else {
        io:println("  ✓ Work order '" + orderId + "' opened for asset '" + assetTag + "'!");
    }
    io:println("");
}

function updateWorkOrder() returns error? {
    io:println("\n─── UPDATE WORK ORDER ─────────────────────────────────────");
    string assetTag = io:readln("  Asset tag: ");
    string orderId = io:readln("  Work order ID: ");
    string status = io:readln("  New status (OPEN/IN_PROGRESS/CLOSED): ");
    string description = io:readln("  Updated description: ");

    json[] tasks = [];
    io:println("  Add/update tasks (type 'done' when finished):");
    int taskNum = 1;
    while true {
        string taskDesc = io:readln("    Task " + taskNum.toString() + " description (or 'done'): ");
        if taskDesc == "done" {
            break;
        }
        tasks.push({
            "taskId": "T" + taskNum.toString(),
            "description": taskDesc
        });
        taskNum = taskNum + 1;
    }

    json payload = {
        "orderId": orderId,
        "status": status,
        "description": description,
        "tasks": tasks
    };

    json|error response = apiClient->put("/assets/" + assetTag + "/workorders/" + orderId, payload);
    if response is error {
        io:println("  ✗ Failed to update work order: " + response.message());
    } else {
        io:println("  ✓ Work order '" + orderId + "' updated successfully!");
    }
    io:println("");
}

function closeWorkOrder() returns error? {
    io:println("\n─── CLOSE WORK ORDER ──────────────────────────────────────");
    string assetTag = io:readln("  Asset tag: ");
    string orderId = io:readln("  Work order ID to close: ");

    json|error response = apiClient->delete("/assets/" + assetTag + "/workorders/" + orderId);
    if response is error {
        io:println("  ✗ Failed to close work order: " + response.message());
    } else {
        io:println("  ✓ Work order '" + orderId + "' closed and removed!");
    }
    io:println("");
}

function listInstitutions() returns error? {
    io:println("\n─── REGISTERED INSTITUTIONS ────────────────────────────────");
    json response = check apiClient->get("/institutions");
    json[] institutions = <json[]>response;

    if institutions.length() == 0 {
        io:println("  No institutions registered.");
    } else {
        foreach var inst in institutions {
            io:println("  ▸ " + (check inst.name).toString() + " (" + (check inst.abbreviation).toString() + ")");
            json[] sites = <json[]>(check inst.sites);
            foreach var site in sites {
                io:println("      • " + site.toString());
            }
        }
    }
    io:println("");
}

function addInstitution() returns error? {
    io:println("\n─── ADD INSTITUTION ────────────────────────────────────────");
    string name = io:readln("  Institution name: ");
    string abbreviation = io:readln("  Abbreviation: ");

    json[] sites = [];
    io:println("  Add campus sites (type 'done' when finished):");
    while true {
        string site = io:readln("    Site name (or 'done'): ");
        if site == "done" {
            break;
        }
        sites.push(site);
    }

    json payload = {
        "name": name,
        "abbreviation": abbreviation,
        "sites": sites
    };

    json|error response = apiClient->post("/institutions", payload);
    if response is error {
        io:println("  ✗ Failed to add institution: " + response.message());
    } else {
        io:println("  ✓ Institution '" + name + "' added successfully!");
    }
    io:println("");
}

function removeInstitution() returns error? {
    io:println("\n─── REMOVE INSTITUTION ─────────────────────────────────────");
    string name = io:readln("  Institution name to remove: ");
    string confirm = io:readln("  Are you sure? (yes/no): ");

    if confirm == "yes" {
        json|error response = apiClient->delete("/institutions/" + name);
        if response is error {
            io:println("  ✗ Failed to remove institution: " + response.message());
        } else {
            io:println("  ✓ Institution '" + name + "' removed successfully!");
        }
    } else {
        io:println("  Removal cancelled.");
    }
    io:println("");
}

function printAssetSummary(json asset) {
    string tag = "";
    string name = "";
    string status = "";
    string institution = "";
    string site = "";

    do {
        tag = (check asset.assetTag).toString();
        name = (check asset.name).toString();
        status = (check asset.status).toString();
        institution = (check asset.institution).toString();
        site = (check asset.site).toString();
    } on fail error e {
        io:println("  [Error reading asset: " + e.message() + "]");
        return;
    }

    string statusIcon = "●";
    if status == "AVAILABLE" {
        statusIcon = "🟢";
    } else if status == "LOANED_OUT" || status == "OCCUPIED" {
        statusIcon = "🔴";
    } else if status == "UNDER_MAINTENANCE" {
        statusIcon = "🟡";
    } else if status == "DISPOSED" {
        statusIcon = "⚫";
    }

    io:println("  " + statusIcon + " [" + tag + "] " + name);
    io:println("     " + institution + " > " + site + " | Status: " + status);
}

function printAssetDetails(json asset) {
    do {
        io:println("  ┌─ Asset Details ─────────────────────────────────────");
        io:println("  │ Tag:         " + (check asset.assetTag).toString());
        io:println("  │ Name:        " + (check asset.name).toString());
        io:println("  │ Description: " + (check asset.description).toString());
        io:println("  │ Institution: " + (check asset.institution).toString());
        io:println("  │ Site:        " + (check asset.site).toString());
        io:println("  │ Status:      " + (check asset.status).toString());
        io:println("  │ Acquired:    " + (check asset.dateAcquired).toString());

        json[] components = <json[]>(check asset.components);
        io:println("  │");
        io:println("  │ Components (" + components.length().toString() + "):");
        if components.length() == 0 {
            io:println("  │   (none)");
        }
        foreach var comp in components {
            io:println("  │   • [" + (check comp.compId).toString() + "] " + (check comp.name).toString());
            io:println("  │     " + (check comp.description).toString());
        }

        json[] schedules = <json[]>(check asset.schedules);
        io:println("  │");
        io:println("  │ Schedules (" + schedules.length().toString() + "):");
        if schedules.length() == 0 {
            io:println("  │   (none)");
        }
        foreach var sched in schedules {
            io:println("  │   • [" + (check sched.scheduleId).toString() + "] " + (check sched.'type).toString());
            io:println("  │     Due: " + (check sched.dueDate).toString() + " - " + (check sched.description).toString());
        }

        json[] workOrders = <json[]>(check asset.workOrders);
        io:println("  │");
        io:println("  │ Work Orders (" + workOrders.length().toString() + "):");
        if workOrders.length() == 0 {
            io:println("  │   (none)");
        }
        foreach var wo in workOrders {
            io:println("  │   • [" + (check wo.orderId).toString() + "] " + (check wo.status).toString() + " - " + (check wo.description).toString());
            json[] tasks = <json[]>(check wo.tasks);
            foreach var task in tasks {
                io:println("  │     → [" + (check task.taskId).toString() + "] " + (check task.description).toString());
            }
        }

        io:println("  └────────────────────────────────────────────────────");
    } on fail error e {
        io:println("  [Error displaying asset details: " + e.message() + "]");
    }
}
