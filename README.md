![Pleb Banner](https://github.com/Tyler-McIntyre/Pleb-LN/blob/master/images/readme/Pleb%20banner.png)

# Power to the Plebs!

Pleb LN is a remote control for your LND node. capable of paying invoices, creating invoices, managing your channels, updating channel policies and viewing your balances all at *lightning* fast speeds. Communicates via gRPC on the [LND api](https://api.lightning.community/). 

A huge thank you to all the Bitcoin, and Lightning devs out there for inspiring this and making it possible.

Quick PSA, Pleb LN **DOES NOT** currently support connecting to your node through the Tor network and I do not reccomend using your node without Tor. You can however connect to your node with Pleb on your home network by using the same host you used to SSH into your node. You **DO NOT** need to disable tor on your node in order to do this.  

<p float="left">
<img src="https://github.com/Tyler-McIntyre/Pleb-LN/blob/master/images/readme/on-chain_screen.png" width="275" height="550">
<img src="https://github.com/Tyler-McIntyre/Pleb-LN/blob/master/images/readme/quick_scan.png" width="275" height="550">
<img src="https://github.com/Tyler-McIntyre/Pleb-LN/blob/master/images/readme/channels_screen.png" width="275" height="550">
</p>

## Testing with polar
Download Polar for testing locally
https://lightningpolar.com/

As of now, Pleb only support LND nodes, so when creating your local network make sure you're using LND nodes only.

You'll need three parameters to make the connection
select a node, select 'connect'
#### If you're using an an android emulator, 
The host will be 10.0.2.2. Android emulators

#### find the port number
Under the connect tab, look at the gRPC host. You'll see the port number listed after the host. I.E. 127.0.0.1:10003. 10003 is your port.

#### find the macaroon
Under hex you'll find the admin macaroon. This delegates read and write permissions to the user. Invoice and read-only are more restrictive. 


### Road map
 - Connecting through Tor
 - Optional pins (Android & IOS) and Face ID (IOS)
 - Keysends
 - On-chain transactions
 - Deep links
 - LNURL withdraw request
 - Pay Joins




