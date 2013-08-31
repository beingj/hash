hash is a GUI tool to help calculate hash when studying IPMI packet, written in Tcl/Tk. Double click hash.exe to start it.

There are some example files in the folder:
1. Wireshark capture file (.pcap)
md5_admin_admin.pcap => IOL 1.5 with authentication type md5, username admin and password admin.
c3_admin_admin.pcap => IOL 2.0 with cipher suite ID 3, username admin and password admin.

2. md5.png
A picture to show how to calculate the md5 authentication code.

3. md5.txt
A text version of md5.png.

4. c3_rakp_msg2.txt
A text file to show how to calculate RAKP Message 2 Key Exchange Authentication Code.

5. c3_aes_cbc.txt
A text file to show how to decrypt the IPMI payload with AES-CBC-128.

6. RMCP+ Packet decrypt and authcode.html
A html version of c3_aes_cbc.txt