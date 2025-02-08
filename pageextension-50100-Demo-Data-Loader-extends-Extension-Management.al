pageextension 50600 "Demo Data Loader" extends "Config. Worksheet"
{
    actions
    {
        addlast(Processing)
        {
            action(ImportDemoData)
            {
                ApplicationArea = All;
                Caption = 'Import Demo Data';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Demo Package Selection";
                ToolTip = 'Opens the list of available demo data packages for import.';
            }

            action(DemoDataSetup)
            {
                ApplicationArea = All;
                Caption = 'Demo Data Setup';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Demo Data Setup";
                ToolTip = 'Opens the Demo Data Setup page to configure storage settings.';
            }
        }
    }
}