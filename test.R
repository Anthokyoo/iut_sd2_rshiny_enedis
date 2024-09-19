---
title: "Test"
output: html_document
---

```{r include = FALSE}
library(viridis)
```

The code below demonstrates two color palettes in the [viridis](https://github.com/sjmgarnier/viridis) package. Each plot displays a contour map of the Maunga Whau volcano in Auckland, New Zealand.

## Viridis colors

```{r}
image(volcano, col = viridis(200))
```

## Magma colors

```{r}
image(volcano, col = viridis(200, option = "A"))
```

## AUTHORIZE ACCOUNT
```{r}
rsconnect::setAccountInfo(name='fmrd2e-anthokyoo', token='3AEAAAFBC31A3D9D3304A5EB67EDBFFD', secret='8FbP1YBWOkAYiJfqxRm0PC/CdSz5nSyKgA7GhNGZ')
```

## DEPLOY
```{r}
library(rsconnect)
    rsconnect::deployApp('path/to/your/app')
```