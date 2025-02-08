table 50600 "Demo Data Setup"
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
            begin
                if "Storage URL" <> '' then
                    if not "Storage URL".StartsWith('https://') then
                        Error(MustStartWithHttpsErr);
            end;
        }
        field(3; "Default Package Name"; Text[250])
        {
            Caption = 'Default Package Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Default Package Name" <> '' then
                    if not "Default Package Name".EndsWith('.rapidstart') then
                        Error(MustEndWithRapidstartErr);
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

    var
        MustEndWithRapidstartErr: Label 'The Package Name must end with .rapidstart';

        MustStartWithHttpsErr: Label 'The Storage URL must start with https://';

    procedure InsertIfNotExists()
    begin
        Reset();
        if not Get() then begin
            Init();
            "Primary Key" := 'SETUP';
            Insert();
        end;
    end;
}