require 'pry'
class Pokemon < ActiveRecord::Base
    has_many :favorite_pokemon
    has_many :user, through: :favorite_pokemon
    belongs_to :type

    def self.search_menu(user)
        # Instatiate new menu prompt
        prompt = TTY::Prompt.new
    
        # Define menu choices
        choices = {
            'Input a Pokemon by Name' => 1,
            'Input a Pokemon by ID' => 2,
            'Select a Pokemon Type to view a list of Pokemon' => 3,
            'Return to Main Menu' => 4
        }
    
        # Display prompt and set variable to user's choice
        menu_response = prompt.select("\nSelect an option to learn more about the first 151 Pokemon:", choices)
    
        # Conditional logic based on user choice selection
        case menu_response
        when 1
            puts "Enter Pokemon Name:"
            poke_name_response = gets.chomp.downcase
            Pokemon.select_pokemon_by_name(poke_name_response,user)
        when 2
            puts "Enter Pokemon ID between 1-151:"
            poke_id_response = gets.chomp
            Pokemon.select_pokemon_by_id(poke_id_response,user)
        when 3
            Type.type_menu(user)
        when 4
            user.main_menu
        end
    end

    def self.select_pokemon_by_name(pokemon_name,user)
        @found_pokemon = all.find_by(name: pokemon_name.downcase)
        if !@found_pokemon
            puts "Could not find that Pokemon. Please try your search again."
            puts "\n"
            search_menu(user)
        else
            @found_pokemon.display_pokemon_info(user)
        end
    end

    def self.select_pokemon_by_id(poke_id,user)
        @found_pokemon_by_id = all.find_by(pokemon_id: poke_id)
        if !@found_pokemon_by_id
            puts "Could not find that Pokemon. Please try your search again."
            puts "\n"
            search_menu(user)
        else
            @found_pokemon_by_id.display_pokemon_info(user)
        end
    end
    
    #Displays all stats for a single pokemon
    def display_pokemon_info(user)
        #Figure out how to render this image in terminal
        #Front sprite
        RestClient.get("https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/#{pokemon_id}.png")
        #Back sprite
        RestClient.get("https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/#{pokemon_id}.png")
        puts "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n"
        puts "Name: #{name.capitalize}"
        puts "Pokemon ID: #{pokemon_id}"
        puts "Height: #{height}"
        puts "Weight: #{weight}"
        puts "Type: #{type_1.capitalize}"
        puts "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
        #figure out what menu follows this
        more_options_menu(user)
    end

    def more_options_menu(user)
        # Instatiate new menu prompt
        prompt = TTY::Prompt.new
    
        # Define menu choices
        choices = {
            'Add Pokemon to my Favorites' => 1,
            'Return to Main Menu' => 4
        }
    
        # Display prompt and set variable to user's choice
        menu_response = prompt.select("\nMore options:", choices)
    
        # Conditional logic based on user choice selection
        case menu_response
        when 1
            add_to_user_favorites(user)
        when 4
            system("clear")
            user.main_menu
        end
    end

    def self.list_pokemon_by_type(pokemon_type, user)
        prompt = TTY::Prompt.new
        pokemon_choices = all.where(type_1: pokemon_type.downcase)
        pokemon_names = pokemon_choices.map do |pokemon|
            pokemon.name.capitalize
        end
        pokemon_choice_response = prompt.select("Select a Pokemon", pokemon_names)
        select_pokemon_by_name(pokemon_choice_response, user)
    end

    def add_to_user_favorites(user_passed)
        FavoritePokemon.create(user: user_passed, pokemon: self)
    end

end
