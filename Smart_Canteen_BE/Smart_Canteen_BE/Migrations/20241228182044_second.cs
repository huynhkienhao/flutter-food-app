using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Smart_Canteen_BE.Migrations
{
    /// <inheritdoc />
    public partial class second : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
            name: "FullName",
            table: "AspNetUsers",
            type: "nvarchar(max)",
            nullable: true, // Allow NULL
            oldClrType: typeof(string),
            oldType: "nvarchar(max)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {

        }
    }
}
