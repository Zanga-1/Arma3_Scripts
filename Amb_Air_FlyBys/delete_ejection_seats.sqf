// Function to delete all objects with specified class names
deleteSeats = {
    // List of class names to delete
    private _ejectionSeatTypes = [
        "rhs_k36d5_seat", 
        "rhs_vs1_seat",
        "rhs_a10_acesII_seat",
        "rhs_vs1_seat"
    ];

    // Get all vehicles on the map
    private _allVehicles = vehicles;
    
    // Iterate through all vehicles
    {
        // Check if the vehicle is in the list of ejection seat class names
        if (typeOf _x in _ejectionSeatTypes) then {
            // Delete the ejection seat
            deleteVehicle _x;
        };
    } forEach _allVehicles;
};

// Execute the function client-side and repeat every 5 minutes
[] spawn {
    while {true} do {
	// Wait for 5 minutes (300 seconds)
        sleep 300;
	
        // Call the delete function
        [] call deleteSeats;
    };
};
