codeunit 50600 "Demo Data Loader"
{
    Access = Internal;

    var
        TempBlob: Codeunit "Temp Blob";
        DemoDataSetup: Record "Demo Data Setup";
        LastErrorText: Text;
        NoSetupErr: Label 'Demo Data Setup is not configured. Please configure it first.';
        EmptyStorageUrlErr: Label 'Storage URL is not configured in Demo Data Setup.';

    procedure GetAvailablePackages(var TempPackageBuffer: Record "Name/Value Buffer" temporary)
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        JResponse: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        ResponseText: Text;
        i: Integer;
    begin
        if not DemoDataSetup.Get() then
            Error(NoSetupErr);

        if DemoDataSetup."Storage URL" = '' then
            Error(EmptyStorageUrlErr);

        // List blobs using Azure Storage REST API
        // Note: This assumes public access is enabled on the container
        if not Client.Get(DemoDataSetup."Storage URL" + '?restype=container&comp=list', Response) then
            Error(GetLastErrorText());

        if not Response.IsSuccessStatusCode() then
            Error(Response.ReasonPhrase);

        Response.Content().ReadAs(ResponseText);

        // Parse the XML response - this could be enhanced with proper XML parsing
        // For now we'll keep it simple and only get .rapidstart files
        JResponse.ReadFrom(ResponseText);

        if JResponse.Get('Blobs', JToken) then begin
            JArray := JToken.AsArray();

            for i := 0 to JArray.Count() - 1 do begin
                JArray.Get(i, JToken);
                if JToken.AsObject().Get('Name', JToken) then begin
                    if JToken.AsValue().AsText().EndsWith('.rapidstart') then begin
                        TempPackageBuffer.Init();
                        TempPackageBuffer.ID := i;
                        TempPackageBuffer.Name := JToken.AsValue().AsText();
                        TempPackageBuffer.Insert();
                    end;
                end;
            end;
        end;
    end;

    procedure LoadDemoData(PackageName: Text): Boolean
    begin
        if not DemoDataSetup.Get() then
            Error(NoSetupErr);

        if DemoDataSetup."Storage URL" = '' then
            Error(EmptyStorageUrlErr);

        exit(LoadDemoDataFull(PackageName, DemoDataSetup."Storage URL"));
    end;

    procedure LoadDemoDataFull(PackageName: Text; StorageUrl: Text): Boolean
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        InStr: InStream;
        OutStr: OutStream;
        ConfigPackageImport: Codeunit "Config. Package - Import";
        ProgressDialog: Dialog;
        ImportingMsg: Label 'Importing demo data package #1...', Comment = '%1 = Package Name';
        DownloadErrorMsg: Label 'Unable to download the package: %1', Comment = '%1 = Error Message';
        FullUrl: Text;
    begin
        ProgressDialog.Open(ImportingMsg);
        ProgressDialog.Update(1, PackageName);

        // Initialize
        Clear(TempBlob);
        ClearLastError();
        TempBlob.CreateOutStream(OutStr);

        // Build full URL
        FullUrl := GetPackageUrl(StorageUrl, PackageName);

        // Download package
        if not Client.Get(FullUrl, Response) then begin
            LastErrorText := GetLastErrorText();
            Error(DownloadErrorMsg, LastErrorText);
        end;

        if not Response.IsSuccessStatusCode() then
            Error(DownloadErrorMsg, Response.ReasonPhrase);

        // Process the package
        Response.Content().ReadAs(InStr);
        CopyStream(OutStr, InStr);

        // Import and apply the configuration package
        ConfigPackageImport.ImportAndApplyRapidStartPackageStream(TempBlob);

        ProgressDialog.Close();
        exit(true);
    end;

    local procedure GetPackageUrl(BaseUrl: Text; PackageName: Text): Text
    begin
        if BaseUrl.EndsWith('/') then
            exit(BaseUrl + PackageName)
        else
            exit(BaseUrl + '/' + PackageName);
    end;

    procedure GetLastError(): Text
    begin
        exit(LastErrorText);
    end;
}