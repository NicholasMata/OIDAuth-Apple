# OIDAuth

The purpose of this library is to make OAuth 2.0 OpenID Authentication simple for your applications. 
It has a very opinionated implementation and might not be for everyone. Under the hood this implementations 
realizes heavily on ASWebAuthenticationSession which is a builtin to iOS, iPadOS, macOS, tvOS, and watchOS.

The main issue I see with most Authentication libraries for iOS specifically is that they typically are just a piece of the puzzle.
Then it is the user of the libraries job to figure out other parts of Authentication in order to use it in a real world case.

**NOTE: Everything about this library is very opinionated. I try to give my reasons for my opinions. Just because I have opinions
does not mean I am not open to listening to any suggestions.**

## Who is this for?

This library is meant for developers who need to authenticate against a 100% OpenID OAuth2.0 Authentication Server. How do you know if
this is you? If you have a well known openid configuration url, this library is for you.

## Setup

Currently only Swift Package Manager support is available and tested. The reason for only supporting SPM is that it is the offical 
package manager for use with xCode. The only reason to be using CocoaPods, Carthage, etc. is if you are maintaining an older project.
If you need support for these other methods raise an issue.

### Swift Package Manager

To use with SPM just simply paste the GitHub repo url into the search. 
`https://github.com/NicholasMata/OIDAuth-Apple`

## Demonstration

Since I hate when repos don't have a demonstration video here is one for this library under iOS. 

*If you would like another demonstration for a different platform create an issue I will do my best to accommodate the request.* 

## How to use this library?

As I stated earlier this library is very opinionated and so is this documentation. You are free to use the library however you like below
I will stating how it is intended to be used, using either UIKit or SwiftUI.

