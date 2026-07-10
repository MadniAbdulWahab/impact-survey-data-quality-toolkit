// SurveyRaw — production import of the synthetic raw extract.
//
// Portfolio artefact using synthetic data only. This query reads the CSV path
// from the workbook's RawDataPath named cell (set it on the Config sheet),
// promotes headers, applies explicit types, trims code values, and joins
// human-readable labels. The label maps below match the Lookups sheet exactly.
//
// How to use: Data > Get Data > From Other Sources > Blank Query, then paste
// this whole script into the Advanced Editor. Keep the query name "SurveyRaw"
// because the pivots and documentation reference that table name.
let
    RawPath = Excel.CurrentWorkbook(){[Name = "RawDataPath"]}[Content]{0}[Column1],

    Source = Csv.Document(
        File.Contents(RawPath),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

    // Trim stray whitespace from the categorical code columns.
    CodeColumns = {
        "survey_round", "region_code", "site_code", "enumerator_code", "consent",
        "age_group", "gender", "disability_access", "participated_training",
        "training_topic", "used_skill", "follow_up_requested", "preferred_channel"
    },
    Trimmed = Table.TransformColumns(
        Promoted,
        List.Transform(CodeColumns, (c) => {c, each if _ = null then null else Text.Trim(_), type text})
    ),

    Typed = Table.TransformColumnTypes(
        Trimmed,
        {
            {"interview_date", type date},
            {"program_start_date", type date},
            {"training_date", type date},
            {"household_size", Int64.Type},
            {"satisfaction_score", Int64.Type},
            {"knowledge_before", Int64.Type},
            {"knowledge_after", Int64.Type},
            {"service_access", Int64.Type},
            {"completion_minutes", type number}
        }
    ),

    // Label maps mirror survey/source/choices.csv and the Lookups sheet.
    RegionLabels = [
        NORTH = "North Region (fictional)",
        SOUTH = "South Region (fictional)",
        EAST = "East Region (fictional)",
        WEST = "West Region (fictional)"
    ],
    RoundLabels = [ROUND_1 = "Round 1", ROUND_2 = "Round 2"],
    TopicLabels = [
        planning = "Planning",
        financial_skills = "Financial skills",
        digital_skills = "Digital skills",
        leadership = "Leadership"
    ],
    ChannelLabels = [
        community_meeting = "Community meeting",
        printed_material = "Printed material",
        radio = "Radio",
        none = "None"
    ],
    LabelOf = (map as record, code as any) as any =>
        if code = null then null else Record.FieldOrDefault(map, code, "UNMAPPED"),

    WithRegionLabel = Table.AddColumn(Typed, "region_label", each LabelOf(RegionLabels, [region_code]), type text),
    WithRoundLabel = Table.AddColumn(WithRegionLabel, "round_label", each LabelOf(RoundLabels, [survey_round]), type text),
    WithTopicLabel = Table.AddColumn(WithRoundLabel, "topic_label", each LabelOf(TopicLabels, [training_topic]), type text),
    WithChannelLabel = Table.AddColumn(WithTopicLabel, "channel_label", each LabelOf(ChannelLabels, [preferred_channel]), type text)
in
    WithChannelLabel
