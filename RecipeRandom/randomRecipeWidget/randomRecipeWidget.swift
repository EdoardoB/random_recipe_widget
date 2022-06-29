//
//  randomRecipeWidget.swift
//  randomRecipeWidget
//
//  Created by Edoardo Benissimo on 28/06/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> RecipeRandomEntry {
        let placeholderRecipe = Recipe(strCategory: "Pasta", strArea: "Italy", strMeal: "Rigatoni", strMealThumb: "https://www.themealdb.com/images/media/meals/kcv6hj1598733479.jpg")
        let entry = RecipeRandomEntry(date: Date(), recipe: placeholderRecipe)
        return entry
    }

    func getSnapshot(in context: Context, completion: @escaping (RecipeRandomEntry) -> ()) {
        let placeholderRecipe = Recipe(strCategory: "Pasta", strArea: "Italy", strMeal: "Rigatoni", strMealThumb: "https://www.themealdb.com/images/media/meals/kcv6hj1598733479.jpg")
        let entry = RecipeRandomEntry(date: Date(), recipe: placeholderRecipe)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!

        RecipeLoader.fetch { result in
            let recipe: Recipe
            if case .success(let recipeFetched) = result {
                recipe = recipeFetched
            } else {
                recipe = Recipe(strCategory: "Failed to load", strArea: "", strMeal: "", strMealThumb: "")
            }
            let entry = RecipeRandomEntry(date: currentDate, recipe: recipe)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

struct RecipeLoader {
    static func fetch(completion: @escaping (Result<Recipe, Error>) -> Void) {
        let baseUrl = URL(string: "https://www.themealdb.com/api/json/v1/1/random.php")!
        let task = URLSession.shared.dataTask(with: baseUrl) { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            let jsonDecoder = JSONDecoder()
            let recipe = try! jsonDecoder.decode(RecipeList.self, from: data!)
            completion(.success(recipe.meals.first!))
        }
        task.resume()
    }
}
struct RecipeList: Decodable {
    let meals: [Recipe]
}
struct Recipe: Decodable {
    let strCategory: String
    let strArea: String
    let strMeal: String
    let strMealThumb: String
    var strIngredient1: String = ""
    var strIngredient2: String = ""
    var strIngredient3: String = ""
    var strMeasure1: String = ""
    var strMeasure2: String = ""
    var strMeasure3: String = ""
    var strInstructions = ""
}
struct RecipeRandomEntry: TimelineEntry {
    let date: Date
    let recipe: Recipe
}
struct RandomRecipeSmall: View {
    var recipe: Provider.Entry
    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor(red: 245.0/255.0, green: 246.0/255.0, blue: 250.0/255.0, alpha: 1))
            VStack(alignment: .center) {
                Text("Random Recipe")
                    .font(.system(size: 16, weight: .bold, design: .default))
                Image(uiImage: recipe.recipe.strMealThumb.load())
                    .frame(width: 64, height: 64)
                    .cornerRadius(10)
                Text(recipe.recipe.strMeal)
                    .font(.system(size: 15, weight: .semibold, design: .default))
                    .multilineTextAlignment(.leading)
                Text("\(recipe.recipe.strArea) • \(recipe.recipe.strCategory)")
                    .font(.system(size: 12, weight: .regular, design: .default))
            }
            .padding()
        }
    }
}

struct RandomRecipeMedium: View {
    var recipe: Provider.Entry
    var body: some View {
        ZStack(alignment: .leading) {
            Color(UIColor(red: 245.0/255.0, green: 246.0/255.0, blue: 250.0/255.0, alpha: 1))
            VStack(alignment: .leading) {
                Text("Today Random Recipe")
                    .font(.system(size: 16, weight: .bold, design: .default))
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Image(uiImage: recipe.recipe.strMealThumb.load())
                            .frame(width: 96, height: 96)
                            .cornerRadius(10)
                    }
                    Spacer()
                        .frame(width: 18)
                    VStack(alignment: .leading) {
                        Text(recipe.recipe.strMeal)
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .multilineTextAlignment(.leading)
                        Text("\(recipe.recipe.strArea) • \(recipe.recipe.strCategory)")
                            .font(.system(size: 10, weight: .regular, design: .default))
                        Spacer()
                            .frame(height: 8)
                        Text("Ingredienti")
                            .font(.system(size: 16, weight: .semibold, design: .default))
                        Text("\(recipe.recipe.strMeasure1) \(recipe.recipe.strIngredient1) - \(recipe.recipe.strMeasure2) \(recipe.recipe.strIngredient2) - \(recipe.recipe.strMeasure3) \(recipe.recipe.strIngredient3)")
                            .font(.system(size: 14, weight: .regular, design: .default))
                    }
                }
            }
            .padding()
        }
    }
}
struct RandomRecipeBig: View {
    var recipe: Provider.Entry
    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor(red: 245.0/255.0, green: 246.0/255.0, blue: 250.0/255.0, alpha: 1))
            VStack(alignment: .leading) {
                Text("Today Random Recipe")
                    .font(.system(size: 16, weight: .bold, design: .default))
                Image(uiImage: recipe.recipe.strMealThumb.load())
                    .frame(width: 320, height: 120)
                    .cornerRadius(10)
                Text("Ingredienti")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                Text("\(recipe.recipe.strMeasure1) \(recipe.recipe.strIngredient1) - \(recipe.recipe.strMeasure2) \(recipe.recipe.strIngredient2) - \(recipe.recipe.strMeasure3) \(recipe.recipe.strIngredient3)")
                    .font(.system(size: 14, weight: .regular, design: .default))
                Spacer()
                    .frame(width: 0, height: 10)
                Text("Istruzioni")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                Text(recipe.recipe.strInstructions)
                    .font(.system(size: 14, weight: .regular, design: .default))
            }
            .padding(EdgeInsets(top: 14, leading: 14, bottom: 0, trailing: 14))
        }
    }
}
struct EmptyView: View {
    var body: some View {
        Text("Error...")
    }
}
struct randomRecipeWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    @ViewBuilder
    var body: some View {
        switch family {
            case .systemSmall:
                RandomRecipeSmall(recipe: entry)
            case .systemMedium:
                RandomRecipeMedium(recipe: entry)
            case .systemLarge:
                RandomRecipeBig(recipe: entry)
            case .systemExtraLarge:
                RandomRecipeBig(recipe: entry)
            @unknown default:
                EmptyView()
        }
    }
}

@main
struct randomRecipeWidget: Widget {
    let kind: String = "randomRecipeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            randomRecipeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge ])
    }
}

extension String {
    func load() -> UIImage {
        do {
            guard let url = URL(string: self) else {
                return UIImage()
            }
            let data: Data = try Data(contentsOf: url)
            return UIImage(data: data) ?? UIImage()
        } catch {
            
        }
        return UIImage()
    }
}
