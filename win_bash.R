# Based on knitr::knit_engines$get('bash')

win_bash <- function (options) 
{
  cmd = 'C:/Users/Derek Slone-Zhen/.babun/cygwin/bin/bash.exe'
  out = if (options$eval) {
    message("running: ", cmd, " ", options$code)
    code <- gsub("\r", "", options$code, fixed = TRUE)
    tmp_file <- tempfile()
    writeChar(code, tmp_file)
    tryCatch(system2(cmd, options$engine.opts, stdout = TRUE, stderr = TRUE, 
                     stdin = tmp_file,
                     env = options$engine.env),
             error = function(e) {
               if (!options$error) 
                 stop(e)
               paste("Error in running command", cmd, code)
             },
             finally = {
               file.remove(tmp_file)
             })
  }
  else ""
  if (!options$error && !is.null(attr(out, "status"))) 
    stop(paste(out, collapse = "\n"))
  knitr::engine_output(options, options$code, out)
}

knitr::knit_engines$set(bash=win_bash)
