# Markdown Acronym

Attempting to replace acronyms in markdown with custom React Components

## Acceptance Criteria

```gherkin
GIVEN a process written in markdown with Acronyms and keywords
AND a acronym input file JSON or YAML
WHEN the build runs
THEN the acronyms and keywords should be updated with a React component
```

## Scenario

The following markdown

```markdown
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
```

With the following YAML

```yaml
UPN: User Principal Name
HTTP: Hypertext Transfer Protocol
HTTPS: Hypertext Transfer Protocol Secure
```

Should result in

```markdown
1. On your local computer, open Windows PowerShell, and run the following command.

    ```powershell
    $UserCredential = Get-Credential
    ```

2. In the Windows PowerShell Credential Request dialog box that opens, enter your <Acr>UPN</Acr> (for example, `chris@contoso.com`) and password, and then click **OK**.

3. Replace `<ServerFQDN>` with the fully qualified domain name of your Exchange server (for example, `mailbox01.contoso.com`) and run the following command:

    ```powershell
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://<ServerFQDN>/PowerShell/ -Authentication Kerberos -Credential $UserCredential
    ```

    :::note
    The ConnectionUri value is <Acr>HTTP</Acr>, not <Acr>HTTPS</Acr>.
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
```

## Restrictions

### Code Blocks

The script shouldn't update anything in a code block. For instance the following example

```markdown
The HTTP service on a server is configured with

    ```powershell
    set-service -name HTTP -port 8080
    ```
```

should result in:

```markdown
The <Acr>HTTP</Acr> service on a server is configured with

    ```powershell
    set-service -name HTTP -port 8080
    ```
```

### Links

No links should be updated either

```markdown
The [HTTP](https://somesite.com) service on a HTTP server is configured with
```

Should result in

```markdown
The [HTTP](https://somesite.com) service on a <Acr>HTTP</Acr> server is configured with
```
