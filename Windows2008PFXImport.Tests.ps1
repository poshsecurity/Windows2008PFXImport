Import-Module $PSScriptRoot\Windows2008PFXImport.psm1 -Force

Describe 'Windows2008PFXImport' {
    Context 'Script Analyzer' {
        It 'Does not have any issues with the Script Analyser - Import-PfxCertificate' {
            Invoke-ScriptAnalyzer $PSScriptRoot\Functions\Import-PfxCertificate.ps1 | Should be $null
        }
    }

    Context 'Import-PfxCertificate Parameter Validation' {
        Out-File -FilePath 'TestDrive:\text.pfx'

        It 'thows an error when $null is submitted as a FilePath' {
            {Import-PfxCertificate -FilePath $null} | should throw
        }

        It 'thows an error when an empty string is submitted as a FilePath' {
            {Import-PfxCertificate -FilePath ''} | should throw
        }

        It 'thows an error when an invalid path is submitted as a FilePath' {
            {Import-PfxCertificate -FilePath 'TestDrive:\thispfxfilewillneverexist.pfx'} | should throw
        }

        It 'thows an error when $null is submitted as a CertStoreLocation' {
            {Import-PfxCertificate -FilePath 'TestDrive:\text.pfx' -CertStoreLocation $null} | should throw
        }

        It 'thows an error when an empty string is submitted as a CertStoreLocation' {
            {Import-PfxCertificate -FilePath 'TestDrive:\text.pfx' -CertStoreLocation ''} | should throw
        }

        It 'thows an error when an invalid path is submitted as a CertStoreLocation' {
            {Import-PfxCertificate -FilePath 'TestDrive:\text.pfx' -CertStoreLocation 'CERT:\neverever\exist'} | should throw
        }
    }

}