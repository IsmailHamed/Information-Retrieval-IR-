<!DOCTYPE html>
<html>
<head>
    <title>@ViewBag.Title</title>
    <link href="@Url.Content("~/Content/demo.css")" rel="stylesheet" type="text/css" />
</head>
<body>
     <div class="content">
        @RenderBody()
    </div>
</body>
</html>