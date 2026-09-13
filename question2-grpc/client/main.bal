import ballerina/io;
import ballerina/grpc;

public function main() returns error? {
    AccommodationServiceClient ep = check new ("http://localhost:9090");

    PropertyRequest propReq = {
        host_id: "host123",
        name: "Sea View Villa",
        location: "Malibu",
        property_type: "Villa",
        price_per_night: 250.0
    };
    PropertyResponse propRes = check ep->add_property(propReq);
    io:println("Added property with ID: ", propRes.property_id);

    Create_usersStreamingClient userStream = check ep->create_users();
    User u1 = {user_id: "u1", name: "Alice", role: HOST, email: "alice@test.com", phone: "123"};
    User u2 = {user_id: "u2", name: "Bob", role: GUEST, email: "bob@test.com", phone: "456"};
    check userStream->sendUser(u1);
    check userStream->sendUser(u2);
    check userStream->complete();
    UserStreamResponse? streamRes = check userStream->receiveUserStreamResponse();
    if streamRes is UserStreamResponse {
        io:println("Stream response: ", streamRes.message);
    }

    Property updateProp = {
        property_id: propRes.property_id,
        host_id: "host123",
        name: "Sea View Villa - Updated",
        location: "Malibu",
        property_type: "Villa",
        price_per_night: 300.0,
        status: "ACTIVE",
        available: true
    };
    UpdatePropertyRequest upReq = {property: updateProp};
    UpdatePropertyResponse upRes = check ep->update_property(upReq);
    io:println("Property update success: ", upRes.success);

    ListPropertiesRequest listReq = {location: "Malibu", max_price: 500.0};
    stream<Property, grpc:Error?> propStream = check ep->list_available_properties(listReq);
    check propStream.forEach(function(Property prop) {
        io:println("Available Property: ", prop.name, " - $", prop.price_per_night);
    });

    SearchPropertyRequest searchReq = {property_id: propRes.property_id};
    Property searchedProp = check ep->search_property(searchReq);
    io:println("Searched property: ", searchedProp.name);

    BookPropertyRequest bookReq = {
        property_id: propRes.property_id,
        guest_id: "u2",
        check_in: "2024-01-10",
        check_out: "2024-01-15"
    };
    BookPropertyResponse bookRes = check ep->book_property(bookReq);
    io:println("Book response: ", bookRes.message, ", Cart ID: ", bookRes.cart_id);

    ConfirmBookingRequest confirmReq = {
        cart_id: bookRes.cart_id,
        guest_id: "u2"
    };
    ConfirmBookingResponse confirmRes = check ep->confirm_booking(confirmReq);
    io:println("Booking confirmed. ID: ", confirmRes.booking.booking_id, " Total Cost: $", confirmRes.booking.total_cost);

    RemovePropertyRequest rmReq = {property_id: propRes.property_id};
    RemovePropertyResponse rmRes = check ep->remove_property(rmReq);
    io:println("Remaining properties count: ", rmRes.remaining_properties.length());
}

