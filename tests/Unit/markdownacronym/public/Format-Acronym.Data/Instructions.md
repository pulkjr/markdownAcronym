1. On your local computer, open Windows PowerShell, and run the following command.

    ```powershell
    $UserCredential = Get-Credential
    ```

2. In the Windows PowerShell Credential Request dialog box that opens, enter your UPN (for example, `chris@contoso.com`) and password, and then click **OK**.

3. Replace `<ServerFQDN>` with the fully qualified domain name of your Exchange server (for example, `mailbox01.contoso.com`) and run the following command:

    ```powershell
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://<ServerFQDN>/PowerShell/ -Authentication Kerberos -Credential $UserCredential
    ```

    :::note
    The ConnectionUri value is HTTP, not HTTPS.
    :::

4. import the exchange modules into memory

    ```powershell
    Import-PSSession $Session -DisableNameChecking
    ```

    :::caution
    Be sure to disconnect the remote PowerShell session when you're finished. If you close the Windows PowerShell window without disconnecting the session, you could use up all the remote PowerShell sessions available to you, and you'll need to wait for the sessions to expire. To disconnect the remote PowerShell session, run the following command:
    :::

    ```powershell
    Remove-PSSession $Session
    ```
