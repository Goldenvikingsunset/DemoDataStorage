page 50601 "Demo Data Setup"
{
    ApplicationArea = All;
    Caption = 'Demo Data Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Demo Data Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Storage URL"; Rec."Storage URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Azure Blob Storage URL where demo data packages are stored.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InsertIfNotExists();
    end;
}