using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightMover : MonoBehaviour
{
    public GameObject sphere;
    public GameObject capsule;
    public GameObject mantis;

    public Light green;
    public Light white;
    public Light red;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        green.transform.RotateAround(sphere.transform.position, Vector3.up, 60 * Time.deltaTime);
        red.transform.RotateAround(capsule.transform.position, Vector3.up, 90 * Time.deltaTime);
        white.transform.position = new Vector3(white.transform.position.x, white.transform.position.y, -7.7f + 1f * Mathf.Sin(Time.time));
    }
}
