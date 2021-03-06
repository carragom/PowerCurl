<# 
 .Synopsis
  A simple curl-like module for PowerShell.

 .Description
  A simple curl-like module for PowerShell

 .Parameter request
  (HTTP) Specifies a custom request method (HTTP Verb) to use when communicating with
  the HTTP server. The specified request will be used instead of the method otherwise
  used (which defaults to GET). Read the HTTP 1.1 specification for details and explanations.

 .Parameter url
  The specified url for the request.

 .Parameter data
  (HTTP) Sends the specified data in a POST request to the HTTP server, 
  in the same way that a browser does when a user has filled in an HTML form and
  presses the submit button. This will cause powercurl to pass the data to the server
  using the content-type application/x-www-form-urlencoded.

 .Parameter get
  Specific days (numbered) to highlight. Used for date ranges such as (25..31).
  Date ranges are specified using Windows PowerShell's range syntax. These dates are
  enclosed in square brackets.

 .Parameter user
  Specify the user name and password to use for server authentication.

 .Example
   # Submit as basic HTTP GET request
   powercurl -X GET http://www.somesite.com

 .Example
   # Twilio Rest API - Retrieve Twilio Account using the 'pcurl' alias
   pcurl -X GET 'https://api.twilio.com/2010-04-01/Accounts/{AccountSid}.xml' -u {AccountSid}:{AuthToken}

 .Example
   # Twilio Rest API - Suspend Twilio Account using the 'curl' alias
   curl -X POST 'https://api.twilio.com/2010-04-01/Accounts/{AccountSid}' -u {AccountSid}:{AuthToken} -d Status=suspsended
   
 .Example
   # Twilio Rest API - Activate Twilio Account using the 'pc' alias
   pc -X POST 'https://api.twilio.com/2010-04-01/Accounts/{AccountSid}' -u {AccountSid}:{AuthToken} -d Status=active
#>
function global:powercurl {
    param(
        [parameter(Mandatory=$false)]
        [alias("X")]
        [string]$request,
        [parameter(Mandatory=$true)]
        [string]$url,
        [parameter(Mandatory=$false)]
        [alias("d")]
        [string]$data,
        [parameter(Mandatory=$false)]
        [alias("G")]
        [string]$get,
        [parameter(Mandatory=$false)]
        [alias("u")]
        [string]$user
    )
    
    if ($data) {
        $verb = "POST"
    }
    if ($request) {
        $verb = $request
    }
    if ($get) {
        $verb = "GET"
    }   

    if (($verb -eq "GET") -and ($data)) {
        $url = "$url?$data"
    }

    $req = [System.Net.WebRequest]::Create($url)
    $req.Method = $verb
    $req.ContentLength = 0
    if ($user) {
        $cred = $user.split(":")
        if ($user) {
            $req.Credentials = new-object System.Net.NetworkCredential($cred[0],$cred[1])
        } else {
            $req.Credentials = [System.Net.CredentialCache]::DefaultCredentials
        }
    }
    if ($verb -eq "POST") {
        $req.ContentType = "application/x-www-form-urlencoded"
        # Write the request
        if ($data) {
            $bytes = [System.Text.Encoding]::ASCII.GetBytes($data)
            $req.ContentLength = $bytes.Length
            $requestStream = $req.GetRequestStream()
            $requestStream.Write($bytes, 0, $bytes.Length) #Push it out there
            $requestStream.Close()
        }
    }
    $response = $req.GetResponse()
    $reader = new-object System.IO.StreamReader($response.GetResponseStream())
    $result = $reader.ReadToEnd()
    $reader.Close()
    $result
}

New-Alias -name pcurl -value powercurl
New-Alias -name pc -value powercurl
New-Alias -name curl -value powercurl

Register-TabExpansion 'powercurl' @{
    'X' = { 
        "GET",
        "POST"
    }
}

Export-ModuleMember -Function powercurl -Alias *