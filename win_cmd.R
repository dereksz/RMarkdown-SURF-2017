# Based on knitr::knit_engines$get('bash')
win_cmd <- function (options) 
{
  cmd = 'C:/WINDOWS/system32/cmd.exe'
  out = if (options$eval) {
    message("running: ", cmd, " ", options$code)
    tmp_file <- tempfile(fileext = ".bat")
    writeLines(options$code, tmp_file)
    opts <- paste(options$engine.opts, "/c", tmp_file) 
    tryCatch(system2(cmd, opts, stdout = TRUE, stderr = TRUE, env = options$engine.env),
             error = function(e) { if (!options$error) stop(e)
               paste("Error in running command", cmd, code)
             },
             finally = { file.remove(tmp_file) })
  } else ""
  if (!options$error && !is.null(attr(out, "status"))) 
    stop(paste(out, collapse = "\n"))
  knitr::engine_output(options, options$code, out)
}
knitr::knit_engines$set(cmd=win_cmd)
