from flask import Flask, render_template, jsonify
from config import project_config, components, deployment_steps, architecture_components

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html', 
                         project_config=project_config,
                         components=components,
                         deployment_steps=deployment_steps,
                         architecture_components=architecture_components)

@app.route('/api/cluster-info')
def cluster_info():
    return jsonify({
        "cluster_name": project_config["cluster_name"],
        "region": project_config["region"],
        "components": list(components["applications"].keys()),
        "status": "Running"
    })

@app.route('/components')
def components_page():
    return render_template('components.html', 
                         components=components,
                         project_config=project_config)  # Add this line

@app.route('/deployment')
def deployment_page():
    return render_template('deployment.html', 
                         deployment_steps=deployment_steps,
                         project_config=project_config)

@app.route('/architecture')
def architecture_page():
    return render_template('architecture.html', 
                         architecture_components=architecture_components,
                         project_config=project_config)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)# Updated Tue Jun 10 20:47:44 BST 2025
# Updated Tue Jun 10 20:54:36 BST 2025
