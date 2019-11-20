# Rezolve iOS Sample App

*Rezolve® Instant Salesware*

Rezolve iOS Sample App is an application created to demonstrate the capabilities of the Rezolve SDK.

This sample code comes configured to use a Rezolve-hosted authentication server, referred to by Rezolve as a RUA server (Rezolve User Authentication). 
You SHOULD NOT use this server for production apps, it is for testing and Sandbox use only. This sample auth configuration is provided so that:

1) you may compile and test the sample code immediately upon receipt, without having to configure your own auth server, and 

2) so that the partner developer may see an example of how the SDK will utilize an external auth server to obtain permission to talk with the Rezolve APIs.

If you have an existing app with an existing authenticating user base, you will want to utilize YOUR auth server to issue JWT tokens, which the Rezolve API will accept.  Details on this process are available here:  http://docs.rezolve.com/docs/#jwt-authentication

If you do not have an existing app, or do not have an existing app server, you have the option to either implement your own auth server and use JWT authentication as described above, or to have Rezolve install a RUA server for you (the same type auth server this sample code is configured to use).  Please discuss authentication options with your project lead and/or your Rezolve representative. 
