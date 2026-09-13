

import ballerina/http;
import ballerina/io;
import ballerina/time;

function init() {
    initSampleData();
    io:println("============================================================");
    io:println("  Library Management System - REST API Service");
    io:println("  Listening on: http://localhost:9090/api");
    io:println("============================================================");
    io:println("  Sample data loaded: " + assetStore.length().toString() + " assets, "
               + institutionStore.length().toString() + " institutions");
    io:println("============================================================");
}

service /api on new http:Listener(9090) {

    resource function get assets(string? institution, string? site) returns Asset[]|http:InternalServerError {
        Asset[] result = [];

        foreach var asset in assetStore {
            boolean matches = true;

            if institution is string && asset.institution != institution {
                matches = false;
            }

            if site is string && asset.site != site {
                matches = false;
            }

            if matches {
                result.push(asset);
            }
        }

        return result;
    }

    resource function get assets/[string assetTag]() returns Asset|http:NotFound {
        Asset? asset = assetStore[assetTag];
        if asset is () {
            return <http:NotFound>{
                body: {message: "Asset with tag '" + assetTag + "' not found.", code: 404}
            };
        }
        return asset;
    }

    resource function post assets(Asset asset) returns Asset|http:Conflict|http:BadRequest {
        
        if asset.assetTag == "" || asset.name == "" {
            return <http:BadRequest>{
                body: {message: "Asset tag and name are required.", code: 400}
            };
        }

        if assetStore.hasKey(asset.assetTag) {
            return <http:Conflict>{
                body: {message: "Asset with tag '" + asset.assetTag + "' already exists.", code: 409}
            };
        }

        if !institutionStore.hasKey(asset.institution) {
            return <http:BadRequest>{
                body: {message: "Institution '" + asset.institution + "' is not registered. Add it first.", code: 400}
            };
        }

        if asset.status != "AVAILABLE" && asset.status != "LOANED_OUT" &&
           asset.status != "OCCUPIED" && asset.status != "UNDER_MAINTENANCE" &&
           asset.status != "DISPOSED" {
            return <http:BadRequest>{
                body: {message: "Invalid status. Must be AVAILABLE, LOANED_OUT, OCCUPIED, UNDER_MAINTENANCE, or DISPOSED.", code: 400}
            };
        }

        assetStore[asset.assetTag] = asset;
        return asset;
    }

    resource function put assets/[string assetTag](Asset asset) returns Asset|http:NotFound|http:BadRequest {
        if !assetStore.hasKey(assetTag) {
            return <http:NotFound>{
                body: {message: "Asset with tag '" + assetTag + "' not found.", code: 404}
            };
        }

        if asset.status != "AVAILABLE" && asset.status != "LOANED_OUT" &&
           asset.status != "OCCUPIED" && asset.status != "UNDER_MAINTENANCE" &&
           asset.status != "DISPOSED" {
            return <http:BadRequest>{
                body: {message: "Invalid status. Must be AVAILABLE, LOANED_OUT, OCCUPIED, UNDER_MAINTENANCE, or DISPOSED.", code: 400}
            };
        }

        Asset updatedAsset = {
            assetTag: assetTag,
            name: asset.name,
            description: asset.description,
            institution: asset.institution,
            site: asset.site,
            status: asset.status,
            dateAcquired: asset.dateAcquired,
            components: asset.components,
            schedules: asset.schedules,
            workOrders: asset.workOrders
        };

        assetStore[assetTag] = updatedAsset;
        return updatedAsset;
    }

    resource function delete assets/[string assetTag]() returns SuccessResponse|http:NotFound {
        if !assetStore.hasKey(assetTag) {
            return <http:NotFound>{
                body: {message: "Asset with tag '" + assetTag + "' not found.", code: 404}
            };
        }

        _ = assetStore.remove(assetTag);
        return {message: "Asset '" + assetTag + "' successfully deleted."};
    }

    resource function get assets/overdue() returns Asset[] {
        Asset[] overdueAssets = [];
        time:Utc currentTime = time:utcNow();

        foreach var asset in assetStore {
            foreach var schedule in asset.schedules {
                if schedule.'type == "MAINTENANCE" {
                    
                    time:Civil|error dueDate = time:civilFromString(schedule.dueDate + "T00:00:00Z");
                    if dueDate is time:Civil {
                        time:Utc|error dueDateUtc = time:utcFromCivil(dueDate);
                        if dueDateUtc is time:Utc {
                            
                            time:Seconds diff = time:utcDiffSeconds(currentTime, dueDateUtc);
                            if diff > 0d {
                                overdueAssets.push(asset);
                                break; 
                            }
                        }
                    }
                }
            }
        }

        return overdueAssets;
    }

    resource function post assets/[string assetTag]/components(Component component) returns Asset|http:NotFound|http:Conflict|http:BadRequest {
        Asset? existing = assetStore[assetTag];
        if existing is () {
            return <http:NotFound>{
                body: {message: "Asset with tag '" + assetTag + "' not found.", code: 404}
            };
        }

        if component.compId == "" || component.name == "" {
            return <http:BadRequest>{
                body: {message: "Component ID and name are required.", code: 400}
            };
        }

        foreach var comp in existing.components {
            if comp.compId == component.compId {
                return <http:Conflict>{
                    body: {message: "Component with ID '" + component.compId + "' already exists on this asset.", code: 409}
                };
            }
        }

        Component[] updatedComponents = [...existing.components, component];
        Asset updatedAsset = {
            assetTag: existing.assetTag,
            name: existing.name,
            description: existing.description,
            institution: existing.institution,
            site: existing.site,
            status: existing.status,
            dateAcquired: existing.dateAcquired,
            components: updatedComponents,
            schedules: existing.schedules,
            workOrders: existing.workOrders
        };
        assetStore[assetTag] = updatedAsset;
        return updatedAsset;
    }

    resource function delete assets/[string assetTag]/components/[string compId]() returns Asset|http:NotFound {
        Asset? existing = assetStore[assetTag];
        if existing is () {
            return <http:NotFound>{
                body: {message: "Asset with tag '" + assetTag + "' not found.", code: 404}
            };
        }

        Component[] updatedComponents = [];
        boolean found = false;
        foreach var comp in existing.components {
            if comp.compId == compId {
                found = true;
            } else {
                updatedComponents.push(comp);
            }
        }

        if !found {
            return <http:NotFound>{
                body: {message: "Component with ID '" + compId + "' not found on asset '" + assetTag + "'.", code: 404}
            };
        }

        Asset updatedAsset = {
            assetTag: existing.assetTag,
            name: existing.name,
            description: existing.description,
            institution: existing.institution,
            site: existing.site,
            status: existing.status,
            dateAcquired: existing.dateAcquired,
            components: updatedComponents,
            schedules: existing.schedules,
            workOrders: existing.workOrders
        };
        assetStore[assetTag] = updatedAsset;
        return updatedAsset;
    }

    resource function post assets/[string assetTag]/schedules(Schedule schedule) returns Asset|http:NotFound|http:Conflict|http:BadRequest {
        Asset? existing = assetStore[assetTag];
        if existing is () {
            return <http:NotFound>{
                body: {message: "Asset with tag '" + assetTag + "' not found.", code: 404}
            };
        }

        if schedule.scheduleId == "" {
            return <http:BadRequest>{
                body: {message: "Schedule ID is required.", code: 400}
            };
        }

        if schedule.'type != "MAINTENANCE" && schedule.'type != "BOOKING" {
            return <http:BadRequest>{
                body: {message: "Schedule type must be 'MAINTENANCE' or 'BOOKING'.", code: 400}
            };
        }

        foreach var sched in existing.schedules {
            if sched.scheduleId == schedule.scheduleId {
                return <http:Conflict>{
                    body: {message: "Schedule with ID '" + schedule.scheduleId + "' already exists on this asset.", code: 409}
                };
            }
        }

        Schedule[] updatedSchedules = [...existing.schedules, schedule];
        Asset updatedAsset = {
            assetTag: existing.assetTag,
            name: existing.name,
            description: existing.description,
            institution: existing.institution,
            site: existing.site,
            status: existing.status,
            dateAcquired: existing.dateAcquired,
            components: existing.components,
            schedules: updatedSchedules,
            workOrders: existing.workOrders
        };
        assetStore[assetTag] = updatedAsset;
        return updatedAsset;
    }

    resource function delete assets/[string assetTag]/schedules/[string scheduleId]() returns Asset|http:NotFound {
        Asset? existing = assetStore[assetTag];
        if existing is () {
            return <http:NotFound>{
                body: {message: "Asset with tag '" + assetTag + "' not found.", code: 404}
            };
        }

        Schedule[] updatedSchedules = [];
        boolean found = false;
        foreach var sched in existing.schedules {
            if sched.scheduleId == scheduleId {
                found = true;
            } else {
                updatedSchedules.push(sched);
            }
        }

        if !found {
            return <http:NotFound>{
                body: {message: "Schedule with ID '" + scheduleId + "' not found on asset '" + assetTag + "'.", code: 404}
            };
        }

        Asset updatedAsset = {
            assetTag: existing.assetTag,
            name: existing.name,
            description: existing.description,
            institution: existing.institution,
            site: existing.site,
            status: existing.status,
            dateAcquired: existing.dateAcquired,
            components: existing.components,
            schedules: updatedSchedules,
            workOrders: existing.workOrders
        };
        assetStore[assetTag] = updatedAsset;
        return updatedAsset;
    }

    resource function post assets/[string assetTag]/workorders(WorkOrder workOrder) returns Asset|http:NotFound|http:Conflict|http:BadRequest {
        Asset? existing = assetStore[assetTag];
        if existing is () {
            return <http:NotFound>{
                body: {message: "Asset with tag '" + assetTag + "' not found.", code: 404}
            };
        }

        if workOrder.orderId == "" || workOrder.description == "" {
            return <http:BadRequest>{
                body: {message: "Work order ID and description are required.", code: 400}
            };
        }

        foreach var wo in existing.workOrders {
            if wo.orderId == workOrder.orderId {
                return <http:Conflict>{
                    body: {message: "Work order with ID '" + workOrder.orderId + "' already exists on this asset.", code: 409}
                };
            }
        }

        WorkOrder newWorkOrder = {
            orderId: workOrder.orderId,
            status: "OPEN",
            description: workOrder.description,
            tasks: workOrder.tasks
        };

        WorkOrder[] updatedWorkOrders = [...existing.workOrders, newWorkOrder];
        Asset updatedAsset = {
            assetTag: existing.assetTag,
            name: existing.name,
            description: existing.description,
            institution: existing.institution,
            site: existing.site,
            status: existing.status,
            dateAcquired: existing.dateAcquired,
            components: existing.components,
            schedules: existing.schedules,
            workOrders: updatedWorkOrders
        };
        assetStore[assetTag] = updatedAsset;
        return updatedAsset;
    }

    resource function put assets/[string assetTag]/workorders/[string orderId](WorkOrder workOrder) returns Asset|http:NotFound|http:BadRequest {
        Asset? existing = assetStore[assetTag];
        if existing is () {
            return <http:NotFound>{
                body: {message: "Asset with tag '" + assetTag + "' not found.", code: 404}
            };
        }

        if workOrder.status != "OPEN" && workOrder.status != "IN_PROGRESS" && workOrder.status != "CLOSED" {
            return <http:BadRequest>{
                body: {message: "Work order status must be 'OPEN', 'IN_PROGRESS', or 'CLOSED'.", code: 400}
            };
        }

        WorkOrder[] updatedWorkOrders = [];
        boolean found = false;
        foreach var wo in existing.workOrders {
            if wo.orderId == orderId {
                found = true;
                updatedWorkOrders.push({
                    orderId: orderId,
                    status: workOrder.status,
                    description: workOrder.description,
                    tasks: workOrder.tasks
                });
            } else {
                updatedWorkOrders.push(wo);
            }
        }

        if !found {
            return <http:NotFound>{
                body: {message: "Work order with ID '" + orderId + "' not found on asset '" + assetTag + "'.", code: 404}
            };
        }

        Asset updatedAsset = {
            assetTag: existing.assetTag,
            name: existing.name,
            description: existing.description,
            institution: existing.institution,
            site: existing.site,
            status: existing.status,
            dateAcquired: existing.dateAcquired,
            components: existing.components,
            schedules: existing.schedules,
            workOrders: updatedWorkOrders
        };
        assetStore[assetTag] = updatedAsset;
        return updatedAsset;
    }

    resource function delete assets/[string assetTag]/workorders/[string orderId]() returns Asset|http:NotFound {
        Asset? existing = assetStore[assetTag];
        if existing is () {
            return <http:NotFound>{
                body: {message: "Asset with tag '" + assetTag + "' not found.", code: 404}
            };
        }

        WorkOrder[] updatedWorkOrders = [];
        boolean found = false;
        foreach var wo in existing.workOrders {
            if wo.orderId == orderId {
                found = true;
            } else {
                updatedWorkOrders.push(wo);
            }
        }

        if !found {
            return <http:NotFound>{
                body: {message: "Work order with ID '" + orderId + "' not found on asset '" + assetTag + "'.", code: 404}
            };
        }

        Asset updatedAsset = {
            assetTag: existing.assetTag,
            name: existing.name,
            description: existing.description,
            institution: existing.institution,
            site: existing.site,
            status: existing.status,
            dateAcquired: existing.dateAcquired,
            components: existing.components,
            schedules: existing.schedules,
            workOrders: updatedWorkOrders
        };
        assetStore[assetTag] = updatedAsset;
        return updatedAsset;
    }

    resource function post assets/[string assetTag]/loan(LoanRequest loanRequest) returns Asset|http:NotFound|http:BadRequest {
        Asset? existing = assetStore[assetTag];
        if existing is () {
            return <http:NotFound>{
                body: {message: "Asset with tag '" + assetTag + "' not found.", code: 404}
            };
        }

        if existing.status != "AVAILABLE" {
            return <http:BadRequest>{
                body: {message: "Asset is not available for loaning. Current status: " + existing.status, code: 400}
            };
        }

        if loanRequest.borrower == "" || loanRequest.returnDate == "" {
            return <http:BadRequest>{
                body: {message: "Borrower name and return date are required.", code: 400}
            };
        }

        string loanId = generateId("LOAN");
        Schedule loanSchedule = {
            scheduleId: loanId,
            'type: "BOOKING",
            dueDate: loanRequest.returnDate,
            description: "Loaned to " + loanRequest.borrower + ". Return by " + loanRequest.returnDate
        };

        Schedule[] updatedSchedules = [...existing.schedules, loanSchedule];
        Asset updatedAsset = {
            assetTag: existing.assetTag,
            name: existing.name,
            description: existing.description,
            institution: existing.institution,
            site: existing.site,
            status: "LOANED_OUT",
            dateAcquired: existing.dateAcquired,
            components: existing.components,
            schedules: updatedSchedules,
            workOrders: existing.workOrders
        };
        assetStore[assetTag] = updatedAsset;
        return updatedAsset;
    }

    resource function post assets/[string assetTag]/book(BookingRequest bookingRequest) returns Asset|http:NotFound|http:BadRequest {
        Asset? existing = assetStore[assetTag];
        if existing is () {
            return <http:NotFound>{
                body: {message: "Asset with tag '" + assetTag + "' not found.", code: 404}
            };
        }

        if existing.status != "AVAILABLE" {
            return <http:BadRequest>{
                body: {message: "Asset is not available for booking. Current status: " + existing.status, code: 400}
            };
        }

        if bookingRequest.bookedBy == "" || bookingRequest.date == "" {
            return <http:BadRequest>{
                body: {message: "Booker name and date are required.", code: 400}
            };
        }

        string bookingId = generateId("BOOK");
        Schedule bookingSchedule = {
            scheduleId: bookingId,
            'type: "BOOKING",
            dueDate: bookingRequest.date,
            description: "Booked by " + bookingRequest.bookedBy + " on " + bookingRequest.date
                         + " from " + bookingRequest.startTime + " to " + bookingRequest.endTime
                         + ". Purpose: " + bookingRequest.purpose
        };

        Schedule[] updatedSchedules = [...existing.schedules, bookingSchedule];
        Asset updatedAsset = {
            assetTag: existing.assetTag,
            name: existing.name,
            description: existing.description,
            institution: existing.institution,
            site: existing.site,
            status: "OCCUPIED",
            dateAcquired: existing.dateAcquired,
            components: existing.components,
            schedules: updatedSchedules,
            workOrders: existing.workOrders
        };
        assetStore[assetTag] = updatedAsset;
        return updatedAsset;
    }

    resource function post assets/[string assetTag]/'return() returns Asset|http:NotFound|http:BadRequest {
        Asset? existing = assetStore[assetTag];
        if existing is () {
            return <http:NotFound>{
                body: {message: "Asset with tag '" + assetTag + "' not found.", code: 404}
            };
        }

        if existing.status != "LOANED_OUT" && existing.status != "OCCUPIED" {
            return <http:BadRequest>{
                body: {message: "Asset is not currently loaned or occupied. Current status: " + existing.status, code: 400}
            };
        }

        Asset updatedAsset = {
            assetTag: existing.assetTag,
            name: existing.name,
            description: existing.description,
            institution: existing.institution,
            site: existing.site,
            status: "AVAILABLE",
            dateAcquired: existing.dateAcquired,
            components: existing.components,
            schedules: existing.schedules,
            workOrders: existing.workOrders
        };
        assetStore[assetTag] = updatedAsset;
        return updatedAsset;
    }

    resource function get institutions() returns Institution[] {
        return institutionStore.toArray();
    }

    resource function get institutions/[string name]() returns Institution|http:NotFound {
        Institution? inst = institutionStore[name];
        if inst is () {
            return <http:NotFound>{
                body: {message: "Institution '" + name + "' not found.", code: 404}
            };
        }
        return inst;
    }

    resource function post institutions(Institution institution) returns Institution|http:Conflict|http:BadRequest {
        if institution.name == "" {
            return <http:BadRequest>{
                body: {message: "Institution name is required.", code: 400}
            };
        }

        if institutionStore.hasKey(institution.name) {
            return <http:Conflict>{
                body: {message: "Institution '" + institution.name + "' already exists.", code: 409}
            };
        }

        institutionStore[institution.name] = institution;
        return institution;
    }

    resource function delete institutions/[string name]() returns SuccessResponse|http:NotFound {
        if !institutionStore.hasKey(name) {
            return <http:NotFound>{
                body: {message: "Institution '" + name + "' not found.", code: 404}
            };
        }

        _ = institutionStore.remove(name);
        return {message: "Institution '" + name + "' successfully removed."};
    }
}

