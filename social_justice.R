library(readxl)
library(dplyr)
library(tidyr)
library(readr)

bf_fl <- "U:/Data/sol_temp/SJ_Health_CYP.xlsx"

excel_sheets(bf_fl)

hhi_lb <- "Percentage of individuals living in households with less than 50 per cent of contemporary median household income, after housing costs"

hhi <- read_excel(bf_fl, "Median HHI") %>%
  select(Year:UK) %>%
  pivot_longer(-Year, names_to = "area_name") %>%
  mutate(timeperiod_sortable = str_replace(Year, "(\\d{4})/(\\d{2})", "\\10401"),
         timeperiod_label = Year, timeperiod_type = "Financial Year",
         indicator = hhi_lb,
         llo = "Londoners' incomes meet their everyday needs",
         area_code = "") %>%
  select(timeperiod_sortable, timeperiod_label, timeperiod_type,
         indicator, llo, area_name, area_code, value)

unf_lb <- "Proportion of Londoners treated unfairly in the last 12 months because of one or several protected characteristics or because of their social class"

unf <- read_excel(bf_fl, "Unfair") %>%
  select(Year:London) %>%
  pivot_longer(-Year, names_to = "area_name") %>%
  mutate(timeperiod_sortable = str_replace(Year, "(\\d{4})-(\\d{2})", "\\10401"),
         timeperiod_label = Year, timeperiod_type = "Financial Year",
         indicator = unf_lb,
         llo = "Londoners are treated fairly and with dignity",
         area_code = "") %>%
  select(timeperiod_sortable, timeperiod_label, timeperiod_type,
         indicator, llo, area_name, area_code, value)


### Pay gaps
gpg <- read_excel(bf_fl, "Gender PG") %>%
  select(Year:UK) %>%
  pivot_longer(-Year, names_to = "area_name") %>%
  mutate(timeperiod_sortable = str_replace(Year, "(\\d{4})", "\\10101"),
         timeperiod_label = as.character(Year), timeperiod_type = "Annual",
         indicator = "Gender pay gap",
         llo = "Londoners are treated fairly and with dignity",
         area_code = "") %>%
  select(timeperiod_sortable, timeperiod_label, timeperiod_type,
         indicator, llo, area_name, area_code, value)


ethpg <- read_excel(bf_fl, "Ethnicity PG") %>%
  select(Year:`Rest of England and Wales`) %>%
  pivot_longer(-Year, names_to = "area_name") %>%
  mutate(timeperiod_sortable = str_replace(Year, "(\\d{4})", "\\10101"),
         timeperiod_label = as.character(Year), timeperiod_type = "Annual",
         indicator = "Ethnicity pay gap",
         llo = "Londoners are treated fairly and with dignity",
         area_code = "") %>%
  select(timeperiod_sortable, timeperiod_label, timeperiod_type,
         indicator, llo, area_name, area_code, value)

dispg <- read_excel(bf_fl, "Disability PG") %>%
  select(Year:UK) %>%
  pivot_longer(-Year, names_to = "area_name") %>%
  mutate(timeperiod_sortable = str_replace(Year, "(\\d{4})", "\\10101"),
         timeperiod_label = as.character(Year), timeperiod_type = "Annual",
         indicator = "Disability pay gap",
         llo = "Londoners are treated fairly and with dignity",
         area_code = "") %>%
  select(timeperiod_sortable, timeperiod_label, timeperiod_type,
         indicator, llo, area_name, area_code, value)


vote_reg <- read_excel(bf_fl, "Vote") %>%
  select(Year:England) %>%
  pivot_longer(-Year, names_to = "area_name") %>%
  mutate(timeperiod_sortable = str_replace(Year, "(\\d{4})", "\\10101"),
         timeperiod_label = as.character(Year), timeperiod_type = "Annual",
         indicator = "Proportion of eligible adults aged 18 and over who are registered for local elections",
         llo = "Londoners have a say in the running of the city",
         area_code = "") %>%
  select(timeperiod_sortable, timeperiod_label, timeperiod_type,
         indicator, llo, area_name, area_code, value)


inf_dec <- read_excel(bf_fl, "Influence decisions") %>%
  select(Year:England) %>%
  pivot_longer(-Year, names_to = "area_name") %>%
  mutate(timeperiod_sortable = str_replace(Year, "(\\d{4})-(\\d{2})", "\\10401"),
         timeperiod_label = Year, timeperiod_type = "Financial Year",
         indicator = "Proportion who agree that they can personally influence decisions affecting their local area",
         llo = "Londoners have a say in the running of the city",
         area_code = "") %>%
  select(timeperiod_sortable, timeperiod_label, timeperiod_type,
         indicator, llo, area_name, area_code, value)


locals <- read_excel(bf_fl, "Locals get on") %>%
  select(Month:Value) %>%
  mutate(timeperiod_sortable = format(Month, "%Y%m%d"),
         timeperiod_label = format(Month, "%b %Y"),
         timeperiod_type = "Monthly",
         indicator = "People from different backgrounds getting on well together in local area",
         llo = "Londoners get on with and support each other",
         area_code = "", area_name = "London") %>%
  select(timeperiod_sortable, timeperiod_label, timeperiod_type,
         indicator, llo, area_name, area_code, value = Value)

fml_vol <- read_excel(bf_fl, "Formal Vol") %>%
  select(Year:England) %>%
  pivot_longer(-Year, names_to = "area_name") %>%
  mutate(timeperiod_sortable = str_replace(Year, "(\\d{4})-(\\d{2})", "\\10401"),
         timeperiod_label = Year, timeperiod_type = "Financial year",
         indicator = "Formal volunteering in the last 12 months",
         llo = "Londoners get on with and support each other",
         area_code = "") %>%
  select(timeperiod_sortable, timeperiod_label, timeperiod_type,
         indicator, llo, area_name, area_code, value)


inf_vol <- read_excel(bf_fl, "Informal vol") %>%
  select(Year:England) %>%
  pivot_longer(-Year, names_to = "area_name") %>%
  mutate(timeperiod_sortable = str_replace(Year, "(\\d{4})-(\\d{2})", "\\10401"),
         timeperiod_label = Year, timeperiod_type = "Financial year",
         indicator = "Informal volunteering in the last 12 months",
         llo = "Londoners get on with and support each other",
         area_code = "") %>%
  select(timeperiod_sortable, timeperiod_label, timeperiod_type,
         indicator, llo, area_name, area_code, value)

hlp <- read_excel(bf_fl, "Help") %>%
  select(Year:England) %>%
  pivot_longer(-Year, names_to = "area_name") %>%
  mutate(timeperiod_sortable = str_replace(Year, "(\\d{4})-(\\d{2})", "\\10401"),
         timeperiod_label = Year, timeperiod_type = "Financial year",
         indicator = "Percentage of adults who definitely or tend to agree with the statement 'if I needed help, there are people who would be there for me'",
         llo = "Londoners get on with and support each other",
         area_code = "") %>%
  select(timeperiod_sortable, timeperiod_label, timeperiod_type,
         indicator, llo, area_name, area_code, value)

# all_sj <- bind_rows(hhi, unf, gpg, ethpg, dispg, vote_reg, inf_dec, locals, fml_vol,
#                     inf_vol, hlp)

dig <- bind_rows(unf, gpg, ethpg, dispg)
supp <- bind_rows(locals, fml_vol, inf_vol, hlp)


write_csv(dig, "U:/Data/sol_temp/llo_dignity_pay_gaps_unfair.csv")
write_csv(supp, "U:/Data/sol_temp/llo_support_eachother.csv")
write_csv(hhi, "U:/Data/sol_temp/llo_incomes_hhi.csv")

