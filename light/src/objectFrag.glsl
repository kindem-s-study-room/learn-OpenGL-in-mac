#version 330 core
struct Material {
    sampler2D diffuse;
    sampler2D specular;
    sampler2D emission;
    float shininess;
};
uniform Material material;

struct Light {
    vec3 position;
    vec3 direction;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float cutOff;
    float outerCutOff;

    float constant;
    float linear;
    float quadratic;
};
uniform Light light;

out vec4 FragColor;
in vec3 Normal;
in vec3 FragPos;
in vec2 TexCoords;

uniform vec3 lightPos;
uniform vec3 viewPos;

void main(){
    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(lightPos - FragPos);
//    vec3 lightDir = normalize(-light.direction);
    float theta = dot(lightDir, -light.direction);
    if(theta > light.cutOff){
        float diff = max(dot(norm, lightDir), 0.0);
        vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse, TexCoords));
        vec3 ambient = light.ambient * vec3(texture(material.diffuse, TexCoords));

        vec3 viewDir = normalize(viewPos - FragPos);
        vec3 reflectDir = reflect(-lightDir, norm);
        float spec = pow(max(dot(norm, reflectDir), 0.0), material.shininess);
        vec3 specular = light.specular * spec *  vec3(texture(material.specular, TexCoords));

        //    vec3 emission = vec3(texture(material.emission, TexCoords));

        float distance = length(lightPos - FragPos);
        float attenuation = 1.0 / (light.constant + light.linear * distance + light.quadratic * distance * distance);
        //the objectColor is include in the Material struct, for example, previous ambient * objectColor =  material.ambient
        vec3 result =( ambient + diffuse + specular ) * attenuation;
        FragColor = vec4(result, 1.0);
    }else{
        FragColor = vec4(light.ambient * vec3(texture(material.diffuse, TexCoords)), 1.0);
    }
}