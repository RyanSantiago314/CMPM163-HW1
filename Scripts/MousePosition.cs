using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MousePosition : MonoBehaviour
{
    Renderer render;
    float cells = 1;

    // Start is called before the first frame update
    void Start()
    {
        render = GetComponent<Renderer>();

        render.material.shader = Shader.Find("Custom/InputEdge");
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetButtonDown("Fire1"))
            cells += 5;
        else if (Input.GetButtonDown("Fire2"))
            cells -= 5;

        if (cells <= 0)
            cells = 1;
        else if (cells > 100)
            cells = 100;

        render.material.SetFloat("_Cells", cells);
        render.material.SetFloat("_mX", Input.mousePosition.x);
        render.material.SetFloat("_mY", Input.mousePosition.y);


        //Debug.Log(Input.mousePosition);
    }
}
