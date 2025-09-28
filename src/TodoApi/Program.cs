using Microsoft.EntityFrameworkCore;
using TodoApi.Models;

using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();

// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

// Add Swagger services
builder.Services.AddEndpointsApiExplorer();

builder.Services.AddDbContext<TodoContext>(opt =>
    opt.UseInMemoryDatabase("TodoList"));
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo 
    { 
        Title = "TodoApi", 
        Version = "v1",
        Description = "A simple Todo API"
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
app.MapOpenApi();

// Enable Swagger UI based on configuration or environment
bool enableSwagger = app.Configuration.GetValue<bool>("EnableSwagger", false)
                     || app.Environment.IsDevelopment()
                     || app.Environment.IsStaging();

if (enableSwagger)
{
    // Enable Swagger middleware
    app.UseSwagger();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/swagger/v1/swagger.json", "TodoApi v1");
        options.SwaggerEndpoint("/openapi/v1.json", "TodoApi OpenAPI v1");
        options.RoutePrefix = "swagger";
        options.DocumentTitle = "TodoApi Documentation";
    });
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

// Optional: redirect "/" to Swagger UI so you don’t hit Azure’s generic 404.
app.MapGet("/", () => Results.Redirect("/swagger")).ExcludeFromDescription();

app.Run();
