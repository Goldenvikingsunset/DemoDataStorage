table 50601 "Demo Data Setup"
{
    Caption = 'Demo Data Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "Storage URL"; Text[250])
        {
            Caption = 'Storage URL';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                MustStartWithHttpsErr: Label 'The Storage URL must start with https://';
            begin
                if "Storage URL" <> '' then
                    if not "Storage URL".StartsWith('https://') then
                        Error(MustStartWithHttpsErr);
            end;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetRecordOnce()
    begin
        if not Get() then begin
            Init();
            "Primary Key" := 'SETUP';
            Insert();
        end;
    end;
}