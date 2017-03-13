//
//  RegisterCredentials.swift
//  SwiftLogin
//
//  Created by Akhilraj Rajkumar on 23/02/17.
//
//

import Foundation
import Turnstile

public class RegisterCredentials: Credentials {
    /// The username with which the user will log in with
    public var username: String = ""
    
    /// The password to be set for the user
    public var password: String = ""
    
    /// Optional first name
    public var firstname: String = ""
    
    /// Optional last name
    public var lastname: String = ""
    
    /// email
    public var email: String = ""
    
    /// Date of birth
    public var dob: Int = 0
    
    /// Gender
    public var gender: String = ""
    
    /// Profile Image identifier
    public var profileimage: String = ""
    
    public init(firstname: String, lastname: String, email: String, password: String, dob: Int, gender: String, profileimage: String = "profile-avtar.png") {
        self.firstname = firstname
        self.lastname = lastname
        self.email = email
        self.username = email
        self.password = password
        self.dob = dob
        self.gender = gender
        self.profileimage = profileimage
    }
}
