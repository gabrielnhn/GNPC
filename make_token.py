
new_token = input("token: ")

low = new_token.lower()
upp = new_token.upper()

print( \
f"""{low}      {{ symbol = symb_{low};
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(\"{low}  \");
          return {upp};
 }}""")



with open("remaining", "a") as file:
    file.write(new_token)