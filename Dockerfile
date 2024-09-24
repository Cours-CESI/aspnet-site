FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["siteweb-aspnet/siteweb-aspnet.csproj", "siteweb-aspnet/"]
RUN dotnet restore "siteweb-aspnet/siteweb-aspnet.csproj"
COPY . .
WORKDIR "/src/siteweb-aspnet"
RUN dotnet build "siteweb-aspnet.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "siteweb-aspnet.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "siteweb-aspnet.dll"]
