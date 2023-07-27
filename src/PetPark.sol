//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "lib/forge-std/src/console.sol";

contract PetPark {
    // Types

    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum Gender {
        Male,
        Female,
        None
    }

    struct User {
        address userAddress;
        uint age;
        Gender gender;
        AnimalType borrowedAnimal;
    }

    // Events

    event Added(AnimalType animalType, uint count);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);

    // State variables

    address public owner;

    mapping(AnimalType => uint) public animalCounts; // Animal Type => count
    mapping(address => User) public users; // user address => User object

    // Functions

    constructor() {
        owner = msg.sender;
    }

    function add(
        AnimalType _animalType,
        uint _count
    ) public onlyOwner onlyValidAnimal(_animalType) {
        animalCounts[_animalType] += _count;
        emit Added(_animalType, _count);
    }

    function borrow(
        uint _age,
        Gender _gender,
        AnimalType _animalType
    ) public onlyValidAnimalType(_animalType) {
        if (users[msg.sender].userAddress == address(0)) {
            User memory newUser = User(
                msg.sender,
                _age,
                _gender,
                AnimalType(0)
            );
            users[msg.sender] = newUser;
        }

        require(_age == users[msg.sender].age, "Invalid Age");
        require(_gender == users[msg.sender].gender, "Invalid Gender");
        require(_age != 0, "Cannot borrow when age zero");

        require(
            users[msg.sender].borrowedAnimal == AnimalType(0),
            "Already adopted a pet"
        );

        require(
            animalCounts[_animalType] != 0,
            "Selected animal not available"
        );

        if (_gender == Gender.Male) {
            require(
                _animalType == AnimalType.Dog || _animalType == AnimalType.Fish,
                "Invalid animal for men"
            );
        }

        if (_gender == Gender.Female) {
            if (_age < 40) {
                require(
                    _animalType != AnimalType.Cat,
                    "Invalid animal for women under 40"
                );
            }
        }
        animalCounts[_animalType] -= 1;
        users[msg.sender].borrowedAnimal = _animalType;
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        User memory currentUser = users[msg.sender];
        require(currentUser.userAddress != address(0), "No borrowed pets");
        AnimalType returningAnimalType = currentUser.borrowedAnimal;
        require(
            currentUser.borrowedAnimal != AnimalType(0),
            "No borrowed pets"
        );
        animalCounts[returningAnimalType] += 1;
        currentUser.borrowedAnimal = AnimalType.None;
        emit Returned(returningAnimalType);
    }

    // Modifiers

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can add animals");
        _;
    }

    modifier onlyValidAnimal(AnimalType _animalType) {
        require(
            _animalType == AnimalType.Fish ||
                _animalType == AnimalType.Cat ||
                _animalType == AnimalType.Dog ||
                _animalType == AnimalType.Rabbit ||
                _animalType == AnimalType.Parrot,
            "Invalid animal"
        );
        _;
    }

    modifier onlyValidAnimalType(AnimalType _animalType) {
        require(
            _animalType == AnimalType.Fish ||
                _animalType == AnimalType.Cat ||
                _animalType == AnimalType.Dog ||
                _animalType == AnimalType.Rabbit ||
                _animalType == AnimalType.Parrot,
            "Invalid animal type"
        );
        _;
    }
}
