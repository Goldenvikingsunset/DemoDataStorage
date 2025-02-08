page 50600 "Demo Package Selection"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Name/Value Buffer";
    SourceTableTemporary = true;
    Caption = 'Available Demo Packages';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Packages)
            {
                field(Name; Rec.Name)
                {
                    Caption = 'Package Name';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the demo data package.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshList)
            {
                ApplicationArea = All;
                Caption = 'Refresh List';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Refreshes the list of available packages from Azure Storage.';

                trigger OnAction()
                begin
                    LoadPackages();
                end;
            }
            action(ImportSelected)
            {
                ApplicationArea = All;
                Caption = 'Import Selected';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Imports the selected demo data package.';

                trigger OnAction()
                var
                    DemoDataLoader: Codeunit "Demo Data Loader";
                    ConfirmQst: Label 'Do you want to import the demo data package %1?';
                begin
                    if Rec.Name = '' then
                        Error('Please select a package to import.');

                    if not Confirm(ConfirmQst, false, Rec.Name) then
                        exit;

                    if DemoDataLoader.LoadDemoData(Rec.Name) then
                        Message('Demo data package imported successfully.');
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        LoadPackages();
    end;

    local procedure LoadPackages()
    var
        DemoDataLoader: Codeunit "Demo Data Loader";
    begin
        Rec.Reset();
        Rec.DeleteAll();
        DemoDataLoader.GetAvailablePackages(Rec);
        CurrPage.Update(false);
    end;
}