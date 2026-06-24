workspace "Example System" "C4 model — the model is defined once; the views below are the navigable C4 levels. Replace this with your real system." {

    !identifiers flat

    model {
        user = person "User" "A user of the system."

        system = softwareSystem "Example System" "Describe what this system does." {
            web = container "Web App" "Delivers the UI and talks to the API." "React" {
                ui = component "UI" "Renders pages and handles user input." "React"
                apiClient = component "API client" "Calls the backend API." "TypeScript"
            }
            api = container "API" "Business logic and HTTP endpoints." "Node.js"
            db = container "Database" "Stores application data." "PostgreSQL" {
                tags "Database"
            }
        }

        ext = softwareSystem "External Service" "A third-party dependency." {
            tags "External"
        }

        # Container-level relationships
        user -> web "Uses" "HTTPS"
        web -> api "Makes API calls to" "JSON/HTTPS"
        api -> db "Reads from and writes to" "SQL"
        api -> ext "Integrates with" "HTTPS"

        # Component-level relationships
        user -> ui "Interacts with"
        ui -> apiClient "Uses"
        apiClient -> api "Calls" "JSON/HTTPS"
    }

    views {
        # Required for the image (code-level) views below to render.
        properties {
            "mermaid.url" "https://mermaid.ink"
            "mermaid.format" "svg"
        }

        systemContext system "context" "System context." {
            include *
            autolayout lr
        }

        container system "containers" "Containers inside the system." {
            include *
            autolayout lr
        }

        component web "web-components" "Components inside the Web App." {
            include *
            autolayout lr
        }

        dynamic web "example-flow" "An example interaction." {
            user -> ui "interacts"
            ui -> apiClient "calls"
            apiClient -> api "requests data"
            autolayout lr
        }

        image apiClient "api-client-classes" {
            mermaid code/example-class.mmd
            title "Code: API client classes"
        }

        styles {
            element "Element" { color #ffffff }
            element "Person" { shape Person background #4f46e5 }
            element "Software System" { background #2563eb }
            element "Container" { background #3b82f6 }
            element "Component" { background #60a5fa }
            element "Database" { shape Cylinder }
            element "External" { background #6b7280 }
            relationship "Relationship" { thickness 2 }
        }
    }
}
