<#
        .SYNOPSIS
        Imports certificates and private keys from a Personal Information Exchange (PFX) file to the destination store.

        This is a port of the code for Windows 2008. Idea from: https://social.technet.microsoft.com/Forums/windowsserver/en-US/e3de0bdc-e6a0-4906-83a1-75278cbcdff3/importpfxcertificate-question?forum=winserverpowershell
        .DESCRIPTION
        The Import-PfxCertificate cmdlet imports certificates and private keys from a PFX file to the destination store. Certificates with and without private keys in the PFX file are imported, along with any external properties that are present.

        Delegation may be required when using this cmdlet with Windows PowerShell remoting and changing user configuration.
        .EXAMPLE
        C:\PS> <example usage>
        Explanation of what the example does
        .INPUTS
        System.String
        A String containing the path to the PFX file.
        .OUTPUTS
        System.Security.Cryptography.X509Certificates.X509Certificate2
        The imported X509Certificate2 object contained in the PFX file that is associated with private keys.
        .NOTES
        This is a port of the code for Windows 2008. Idea from: https://social.technet.microsoft.com/Forums/windowsserver/en-US/e3de0bdc-e6a0-4906-83a1-75278cbcdff3/importpfxcertificate-question?forum=winserverpowershell
#>
function Import-PfxCertificate
{
    [CMDLetBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param
    (
        # Specifies the path for the PFX file.
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -Path $_ })]
        [String]
        $FilePath,

        # Specifies the path of the store to which certificates will be imported. If this parameter is not specified, then the current path is used as the destination store.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -Path $_ })]
        [String]
        $CertStoreLocation = 'Cert:\localMachine\My',

        # Specifies whether the imported private key can be exported. If this parameter is not specified, then the private key cannot be exported.
        [Parameter(Mandatory = $false)]
        [Switch]
        $Exportable,

        # Specifies the password for the imported PFX file in the form of a secure string.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [SecureString]
        $Password = ''
    )
    
    begin
    {
        $CertStoreLocationWithoutQualifier = Split-Path -Path $CertStoreLocation -NoQualifier 
        $certRootStore = (Split-Path -Path $CertStoreLocationWithoutQualifier -Parent).trim('\')
        $certStore = Split-Path -Path $CertStoreLocationWithoutQualifier -Leaf
    }
    
    process
    {
        $Message = 'Item: {0} Destination: {1}' -f $FilePath, $certStore
        if ($PSCmdlet.ShouldProcess($Message, 'Import PFX certificate'))
        {
            $pfx = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 

            if ($Exportable)
            {
                $pfx.import($FilePath,$Password,'Exportable,PersistKeySet')
            }
            else
            {
                $pfx.import($FilePath,$Password,'PersistKeySet')
            }

            $store = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Store -ArgumentList ($certStore, $certRootStore) 
            
            $store.open('ReadWrite') 
            
            $store.add($pfx) 
            
            $store.close() 
        }

        Write-Output -InputObject $pfx
    }
}
