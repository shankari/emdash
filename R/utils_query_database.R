#' Query functions
#'
#' @param cons a list of connections created with [connect_stage_collections()].
#'
#' @return a data.frame/data.table.
#' @name query
#' @export

#' @rdname query
#' @export
query_cleaned_trips <- function(cons) {
  cons$Stage_analysis_timeseries$find('{"metadata.key": "analysis/cleaned_trip"}') %>%
    as.data.table() %>%
    normalise_uuid() %>%
    data.table::setorder(data.end_fmt_time)
}

#' @rdname query
#' @export
query_cleaned_place <- function(cons) {
  cons$Stage_analysis_timeseries$find('{"metadata.key": "analysis/cleaned_place"}') %>%
    as.data.table() %>%
    normalise_uuid()
}

#' @rdname query
#' @export
query_cleaned_section <- function(cons) {
  cons$Stage_analysis_timeseries$find('{"metadata.key": "analysis/cleaned_section"}') %>%
    as.data.table() %>%
    normalise_uuid()
}

#' @rdname query
#' @export
query_raw_trips <- function(cons) {
  cons$Stage_analysis_timeseries$find('{"metadata.key": "segmentation/raw_trip"}') %>%
    as.data.table() %>%
    normalise_uuid() %>%
    data.table::setorder(data.end_fmt_time)
}

#' @rdname query
#' @export
query_stage_uuids <- function(cons) {
  cons$Stage_uuids$find() %>%
    as.data.table(.) %>%
    normalise_uuid(., keep_uuid = FALSE)
}

#' @rdname query
#' @export
query_stage_profiles <- function(cons) {
  cons$Stage_Profiles$find() %>%
    as.data.table() %>%
    normalise_uuid(., keep_uuid = FALSE) %>%
    convert_datetime_string_to_datetime(cols = c("update_ts"))
}

#' Normalise UUID
#' 
#' @description 
#' Note that this function will rename `uuid` to `user_id`. 
#'
#' @param .data a data.frame created using `query_*` functions in `R/utils_query_database.R`.
#' @param keep_uuid a logical value default as FALSE. If this is true then the
#' original `uuid` field will not be removed from `.data`.
#'
#' @return a data.frame
#' @export
normalise_uuid <- function(.data, keep_uuid = FALSE) {
  if (!is.data.table(.data)) {
    setDT(.data)
  }
  print(names(.data))
  if (!"uuid" %in% names(.data)) {
    stop("`uuid` is not a valid column name in `.data`.")
  }
  # the `uuid` field is a list column, so it has to be converted into a character.
  .data[, user_id := sapply(uuid, function(.x) paste0(unlist(.x), collapse = ""))]
  if (!keep_uuid) {
    .data[, uuid := NULL]
  }
  .data
}

#' Convert character columns to datetime columns
#'
#' @param .data a data.frame.
#' @param cols columns to convert to datetime columns.
#' @param tz time zone. Default as "Australia/Sydney".
#'
#' @return .data
#' @export
convert_datetime_string_to_datetime <- function(.data, cols, tz = "Australia/Sydney") {
  stopifnot(data.table::is.data.table(.data))
  .data[, c(cols) := lapply(.SD, function(.x) {lubridate::as_datetime(.x, tz = tz)}), .SDcols = cols]
}
